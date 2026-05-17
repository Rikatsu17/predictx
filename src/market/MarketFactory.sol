// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PredictionMarket.sol";
import "../token/PredictAIOutcomeShares.sol";

contract MarketFactory {
    address public immutable outcomeShares;

    address[] public markets;
    address public oracle;

    event MarketCreated(address indexed market, string question, uint256 endTime);

    constructor(address _outcomeShares, address _oracle) {
        outcomeShares = _outcomeShares;

        oracle = _oracle;
    }

    function createMarket(string memory question, uint256 endTime, bytes32 salt) external returns (address) {
        PredictionMarket market = new PredictionMarket{salt: salt}(outcomeShares, oracle, question, endTime);
        PredictAIOutcomeShares(outcomeShares).grantMarketRole(address(market));

        markets.push(address(market));

        emit MarketCreated(address(market), question, endTime);

        return address(market);
    }

    function getMarkets() external view returns (address[] memory) {
        return markets;
    }
}
