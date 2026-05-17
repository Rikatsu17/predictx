// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PredictionMarket.sol";
import "../token/PredictAIOutcomeShares.sol";

contract MarketFactory is Ownable {
    address public immutable settlementToken;
    address public immutable outcomeShares;
    address public feeVault;
    address public defaultOracle;
    uint256 public defaultDisputeWindow;

    address[] public markets;

    event MarketCreated(
        address indexed creator,
        address indexed market,
        string question,
        uint256 endTime,
        address oracle,
        bool deterministic
    );
    event DefaultOracleUpdated(address indexed oracle);
    event FeeVaultUpdated(address indexed feeVault);
    event DisputeWindowUpdated(uint256 disputeWindow);

    constructor(
        address _settlementToken,
        address _outcomeShares,
        address _defaultOracle,
        address _feeVault,
        uint256 _defaultDisputeWindow
    ) Ownable(msg.sender) {
        settlementToken = _settlementToken;
        outcomeShares = _outcomeShares;
        defaultOracle = _defaultOracle;
        feeVault = _feeVault;
        defaultDisputeWindow = _defaultDisputeWindow;
    }

    function createMarket(string memory question, uint256 endTime, bytes32 salt) external returns (address) {
        return _createMarketDeterministic(question, endTime, salt, defaultOracle);
    }

    function createMarketWithCreate(string memory question, uint256 endTime) external returns (address market) {
        market = address(
            new PredictionMarket(
                settlementToken,
                outcomeShares,
                defaultOracle,
                feeVault,
                question,
                endTime,
                defaultDisputeWindow,
                owner()
            )
        );

        _registerMarket(msg.sender, market, question, endTime, defaultOracle, false);
    }

    function createMarketWithOracle(
        string memory question,
        uint256 endTime,
        bytes32 salt,
        address oracle
    ) external returns (address) {
        return _createMarketDeterministic(question, endTime, salt, oracle);
    }

    function getMarkets() external view returns (address[] memory) {
        return markets;
    }

    function updateOracle(address newOracle) external onlyOwner {
        defaultOracle = newOracle;
        emit DefaultOracleUpdated(newOracle);
    }

    function updateFeeVault(address newFeeVault) external onlyOwner {
        feeVault = newFeeVault;
        emit FeeVaultUpdated(newFeeVault);
    }

    function updateDisputeWindow(uint256 newDisputeWindow) external onlyOwner {
        require(newDisputeWindow > 0, "invalid dispute window");
        defaultDisputeWindow = newDisputeWindow;
        emit DisputeWindowUpdated(newDisputeWindow);
    }

    function _createMarketDeterministic(
        string memory question,
        uint256 endTime,
        bytes32 salt,
        address oracle
    ) internal returns (address market) {
        market = address(
            new PredictionMarket{salt: salt}(
                settlementToken,
                outcomeShares,
                oracle,
                feeVault,
                question,
                endTime,
                defaultDisputeWindow,
                owner()
            )
        );

        _registerMarket(msg.sender, market, question, endTime, oracle, true);
    }

    function _registerMarket(
        address creator,
        address market,
        string memory question,
        uint256 endTime,
        address oracle,
        bool deterministic
    ) internal {
        PredictAIOutcomeShares(outcomeShares).grantMarketRole(market);
        markets.push(market);

        emit MarketCreated(creator, market, question, endTime, oracle, deterministic);
    }
}
