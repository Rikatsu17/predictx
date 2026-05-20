// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../token/PredictAIOutcomeShares.sol";

import "../interfaces/IOracleAdapter.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PredictionMarket is ReentrancyGuard {
    PredictAIOutcomeShares public immutable outcomeShares;

    string public question;

    uint256 public endTime;

    bool public resolved;

    bool public outcome;

    IOracleAdapter public oracle;
    uint256 public totalYesShares;
    uint256 public yesReserve;

    uint256 public noReserve;

    uint256 public constant FEE_BPS = 30;

    uint256 public constant BPS_DENOMINATOR = 10000;

    uint256 public totalNoShares;

    uint256 public constant YES = 1;

    uint256 public constant NO = 2;

    constructor(address _outcomeShares, address _oracle, string memory _question, uint256 _endTime) {
        outcomeShares = PredictAIOutcomeShares(_outcomeShares);

        oracle = IOracleAdapter(_oracle);

        question = _question;

        endTime = _endTime;
    }

    function buyYesShares(uint256 amount) external {
        require(block.timestamp < endTime, "Market ended");
        require(!resolved, "market resolved");
        totalYesShares += amount;

        outcomeShares.mint(msg.sender, YES, amount);
    }

    function buyNoShares(uint256 amount) external {
        require(block.timestamp < endTime, "Market ended");
        require(!resolved, "market resolved");
        totalNoShares += amount;

        outcomeShares.mint(msg.sender, NO, amount);
    }

    function resolveMarket() external {
        require(block.timestamp >= endTime, "Market active");

        require(!resolved, "Already resolved");

        require(!oracle.isStale(), "Oracle stale");

        resolved = true;

        outcome = oracle.getOutcome();
    }

    function provideLiquidity(uint256 yesAmount, uint256 noAmount) external {
        require(yesAmount > 0 && noAmount > 0, "Invalid liquidity");
        require(!resolved, "market resolved");
        yesReserve += yesAmount;

        noReserve += noAmount;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0, "Invalid input");
        require(reserveIn > 0 && reserveOut > 0, "No liquidity");

        uint256 amountInWithFee = Math.mulDiv(amountIn, BPS_DENOMINATOR - FEE_BPS, BPS_DENOMINATOR);
        uint256 denominator = reserveIn + amountInWithFee;
        if (denominator < reserveIn) {
            return reserveOut;
        }

        uint256 amountOut = Math.mulDiv(amountInWithFee, reserveOut, denominator);
        return amountOut == 0 ? 1 : amountOut;
    }

    function swapYesForNo(uint256 yesIn, uint256 minNoOut) external nonReentrant returns (uint256 noOut) {
        noOut = getAmountOut(yesIn, yesReserve, noReserve);
        require(!resolved, "market resolved");
        require(noOut >= minNoOut, "Slippage exceeded");
        require(yesIn < yesReserve, "swap too large");
        yesReserve += yesIn;

        noReserve -= noOut;
    }

    function swapNoForYes(uint256 noIn, uint256 minYesOut) external nonReentrant returns (uint256 yesOut) {
        yesOut = getAmountOut(noIn, noReserve, yesReserve);
        require(!resolved, "market resolved");
        require(yesOut >= minYesOut, "Slippage exceeded");
        require(noIn < noReserve, "swap too large");
        noReserve += noIn;

        yesReserve -= yesOut;
    }

    function getYesProbability() external view returns (uint256) {
        uint256 total = yesReserve + noReserve;

        if (total == 0) {
            return 0;
        }

        return (yesReserve * 100) / total;
    }
}
