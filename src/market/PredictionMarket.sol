// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import {PredictAIOutcomeShares} from "../token/PredictAIOutcomeShares.sol";
import {PredictionMarketLPToken} from "../token/PredictionMarketLPToken.sol";
import {IOracleAdapter} from "../interfaces/IOracleAdapter.sol";

contract PredictionMarket is Ownable, Pausable, ReentrancyGuard, ERC1155Holder {
    using SafeERC20 for IERC20;

    uint256 public constant FEE_BPS = 30;
    uint256 public constant PROTOCOL_FEE_BPS = 5;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    IERC20 public immutable settlementToken;
    PredictAIOutcomeShares public immutable outcomeShares;
    IOracleAdapter public oracle;
    PredictionMarketLPToken public immutable lpToken;
    address public immutable feeVault;

    string public question;
    uint256 public endTime;
    uint256 public disputeWindow;
    uint256 public resolutionTimestamp;

    bool public resolved;
    bool public finalized;
    bool public disputed;
    bool public outcome;

    uint256 public totalYesShares;
    uint256 public totalNoShares;
    uint256 public totalCollateralLocked;
    uint256 public yesReserve;
    uint256 public noReserve;
    uint256 public yesTokenId;
    uint256 public noTokenId;

    event SharesPurchased(address indexed buyer, uint256 indexed tokenId, uint256 collateralIn, uint256 sharesOut);
    event LiquidityAdded(address indexed provider, uint256 yesAmount, uint256 noAmount, uint256 lpSharesMinted);
    event LiquidityRemoved(address indexed provider, uint256 yesAmount, uint256 noAmount, uint256 lpSharesBurned);
    event Swap(address indexed trader, uint256 indexed tokenIn, uint256 amountIn, uint256 indexed tokenOut, uint256 amountOut);
    event MarketResolved(bool outcome, uint256 resolvedAt);
    event MarketFinalized(bool outcome, uint256 finalizedAt);
    event MarketDisputed(address indexed caller, string reason);
    event WinningsClaimed(address indexed claimant, uint256 tokenId, uint256 sharesBurned, uint256 collateralOut);
    event OracleUpdated(address indexed newOracle);

    constructor(
        address _settlementToken,
        address _outcomeShares,
        address _oracle,
        address _feeVault,
        string memory _question,
        uint256 _endTime,
        uint256 _disputeWindow,
        address _owner
    ) Ownable(_owner) {
        require(_settlementToken != address(0), "invalid settlement token");
        require(_outcomeShares != address(0), "invalid shares");
        require(_oracle != address(0), "invalid oracle");
        require(_feeVault != address(0), "invalid fee vault");
        require(_endTime > block.timestamp, "invalid end time");
        require(_disputeWindow > 0, "invalid dispute window");

        settlementToken = IERC20(_settlementToken);
        outcomeShares = PredictAIOutcomeShares(_outcomeShares);
        oracle = IOracleAdapter(_oracle);
        feeVault = _feeVault;
        question = _question;
        endTime = _endTime;
        disputeWindow = _disputeWindow;

        yesTokenId = uint256(keccak256(abi.encodePacked(address(this), "YES")));
        noTokenId = uint256(keccak256(abi.encodePacked(address(this), "NO")));

        lpToken = new PredictionMarketLPToken("PredictX LP", "PXLP", address(this));
    }

    function buyYesShares(uint256 collateralAmount) external nonReentrant whenNotPaused {
        _buyShares(collateralAmount, yesTokenId, true);
    }

    function buyNoShares(uint256 collateralAmount) external nonReentrant whenNotPaused {
        _buyShares(collateralAmount, noTokenId, false);
    }

    function provideLiquidity(uint256 yesAmount, uint256 noAmount) external nonReentrant whenNotPaused returns (uint256 lpSharesMinted) {
        require(!resolved, "market resolved");
        require(yesAmount > 0 && noAmount > 0, "invalid liquidity");

        outcomeShares.safeTransferFrom(msg.sender, address(this), yesTokenId, yesAmount, "");
        outcomeShares.safeTransferFrom(msg.sender, address(this), noTokenId, noAmount, "");

        uint256 supply = lpToken.totalSupply();
        if (supply == 0) {
            lpSharesMinted = Math.sqrt(yesAmount * noAmount);
        } else {
            uint256 yesSharesMinted = Math.mulDiv(yesAmount, supply, yesReserve);
            uint256 noSharesMinted = Math.mulDiv(noAmount, supply, noReserve);
            lpSharesMinted = yesSharesMinted < noSharesMinted ? yesSharesMinted : noSharesMinted;
        }

        require(lpSharesMinted > 0, "zero lp shares");

        yesReserve += yesAmount;
        noReserve += noAmount;
        lpToken.mint(msg.sender, lpSharesMinted);

        emit LiquidityAdded(msg.sender, yesAmount, noAmount, lpSharesMinted);
    }

    function removeLiquidity(uint256 lpSharesBurned) external nonReentrant returns (uint256 yesAmount, uint256 noAmount) {
        require(lpSharesBurned > 0, "invalid lp amount");

        uint256 supply = lpToken.totalSupply();
        require(supply > 0, "no lp supply");

        yesAmount = Math.mulDiv(lpSharesBurned, yesReserve, supply);
        noAmount = Math.mulDiv(lpSharesBurned, noReserve, supply);
        require(yesAmount > 0 && noAmount > 0, "zero liquidity");

        lpToken.burn(msg.sender, lpSharesBurned);
        yesReserve -= yesAmount;
        noReserve -= noAmount;

        outcomeShares.safeTransferFrom(address(this), msg.sender, yesTokenId, yesAmount, "");
        outcomeShares.safeTransferFrom(address(this), msg.sender, noTokenId, noAmount, "");

        emit LiquidityRemoved(msg.sender, yesAmount, noAmount, lpSharesBurned);
    }

    function swapYesForNo(uint256 yesIn, uint256 minNoOut) external nonReentrant whenNotPaused returns (uint256 noOut) {
        require(!resolved, "market resolved");
        noOut = getAmountOut(yesIn, yesReserve, noReserve);
        require(noOut >= minNoOut, "slippage exceeded");
        require(noOut < noReserve, "insufficient reserve");

        outcomeShares.safeTransferFrom(msg.sender, address(this), yesTokenId, yesIn, "");
        outcomeShares.safeTransferFrom(address(this), msg.sender, noTokenId, noOut, "");

        yesReserve += yesIn;
        noReserve -= noOut;

        emit Swap(msg.sender, yesTokenId, yesIn, noTokenId, noOut);
    }

    function swapNoForYes(uint256 noIn, uint256 minYesOut) external nonReentrant whenNotPaused returns (uint256 yesOut) {
        require(!resolved, "market resolved");
        yesOut = getAmountOut(noIn, noReserve, yesReserve);
        require(yesOut >= minYesOut, "slippage exceeded");
        require(yesOut < yesReserve, "insufficient reserve");

        outcomeShares.safeTransferFrom(msg.sender, address(this), noTokenId, noIn, "");
        outcomeShares.safeTransferFrom(address(this), msg.sender, yesTokenId, yesOut, "");

        noReserve += noIn;
        yesReserve -= yesOut;

        emit Swap(msg.sender, noTokenId, noIn, yesTokenId, yesOut);
    }

    function resolveMarket() external {
        require(block.timestamp >= endTime, "market active");
        require(!resolved, "already resolved");
        require(!oracle.isStale(), "oracle stale");

        resolved = true;
        disputed = false;
        outcome = oracle.getOutcome();
        resolutionTimestamp = block.timestamp;

        emit MarketResolved(outcome, resolutionTimestamp);
    }

    function disputeMarket(string calldata reason) external onlyOwner {
        require(resolved, "not resolved");
        require(!finalized, "already finalized");
        require(block.timestamp <= resolutionTimestamp + disputeWindow, "dispute window passed");

        disputed = true;
        emit MarketDisputed(msg.sender, reason);
    }

    function finalizeMarket() external {
        require(resolved, "not resolved");
        require(!disputed, "market disputed");
        require(!finalized, "already finalized");
        require(block.timestamp > resolutionTimestamp + disputeWindow, "dispute window active");

        finalized = true;
        emit MarketFinalized(outcome, block.timestamp);
    }

    function claimWinnings(uint256 sharesAmount) external nonReentrant returns (uint256 collateralOut) {
        require(finalized, "market not finalized");
        require(sharesAmount > 0, "invalid amount");

        uint256 winningTokenId = outcome ? yesTokenId : noTokenId;
        outcomeShares.burn(msg.sender, winningTokenId, sharesAmount);

        collateralOut = sharesAmount;
        totalCollateralLocked -= collateralOut;
        settlementToken.safeTransfer(msg.sender, collateralOut);

        emit WinningsClaimed(msg.sender, winningTokenId, sharesAmount, collateralOut);
    }

    function updateOracle(address newOracle) external onlyOwner {
        require(newOracle != address(0), "invalid oracle");
        oracle = IOracleAdapter(newOracle);
        emit OracleUpdated(newOracle);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0, "invalid input");
        require(reserveIn > 0 && reserveOut > 0, "no liquidity");

        uint256 amountInWithFee = Math.mulDiv(amountIn, BPS_DENOMINATOR - FEE_BPS, BPS_DENOMINATOR);
        uint256 denominator = reserveIn + amountInWithFee;
        uint256 amountOut = Math.mulDiv(amountInWithFee, reserveOut, denominator);

        return amountOut;
    }

    function getYesProbability() external view returns (uint256) {
        uint256 total = yesReserve + noReserve;
        if (total == 0) {
            return 0;
        }

        return Math.mulDiv(yesReserve, 100, total);
    }

    function _buyShares(uint256 collateralAmount, uint256 tokenId, bool isYes) internal {
        require(block.timestamp < endTime, "market ended");
        require(!resolved, "market resolved");
        require(collateralAmount > 0, "invalid amount");

        settlementToken.safeTransferFrom(msg.sender, address(this), collateralAmount);

        uint256 protocolFee = Math.mulDiv(collateralAmount, PROTOCOL_FEE_BPS, BPS_DENOMINATOR);
        uint256 sharesOut = collateralAmount - protocolFee;
        if (protocolFee > 0) {
            settlementToken.safeTransfer(feeVault, protocolFee);
        }

        totalCollateralLocked += sharesOut;
        if (isYes) {
            totalYesShares += sharesOut;
        } else {
            totalNoShares += sharesOut;
        }

        outcomeShares.mint(msg.sender, tokenId, sharesOut);

        emit SharesPurchased(msg.sender, tokenId, collateralAmount, sharesOut);
    }
}
