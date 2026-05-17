// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../token/PredictAIOutcomeShares.sol";

contract PredictionMarket {
    PredictAIOutcomeShares public immutable outcomeShares;

    string public question;

    uint256 public endTime;

    bool public resolved;

    bool public outcome;

    uint256 public totalYesShares;
    uint256 public yesReserve;

    uint256 public noReserve;

    uint256 public constant FEE_BPS = 30;

    uint256 public constant BPS_DENOMINATOR = 10000;

    uint256 public totalNoShares;

    uint256 public constant YES = 1;

    uint256 public constant NO = 2;

    constructor(address _outcomeShares, string memory _question, uint256 _endTime) {
        outcomeShares = PredictAIOutcomeShares(_outcomeShares);

        question = _question;

        endTime = _endTime;
    }

    function buyYesShares(uint256 amount) external {
        require(block.timestamp < endTime, "Market ended");

        totalYesShares += amount;

        outcomeShares.mint(msg.sender, YES, amount);
    }

    function buyNoShares(uint256 amount) external {
        require(block.timestamp < endTime, "Market ended");

        totalNoShares += amount;

        outcomeShares.mint(msg.sender, NO, amount);
    }

    function resolveMarket(bool _outcome) external {
        require(block.timestamp >= endTime, "Market active");

        require(!resolved, "Already resolved");

        resolved = true;

        outcome = _outcome;
    }

    function provideLiquidity(uint256 yesAmount, uint256 noAmount) external {
        require(yesAmount > 0 && noAmount > 0, "Invalid liquidity");

        yesReserve += yesAmount;

        noReserve += noAmount;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0, "Invalid input");

        require(reserveIn > 0 && reserveOut > 0, "No liquidity");

        uint256 amountInWithFee = amountIn * (BPS_DENOMINATOR - FEE_BPS);

        uint256 numerator = amountInWithFee * reserveOut;

        uint256 denominator = reserveIn * BPS_DENOMINATOR + amountInWithFee;

        return numerator / denominator;
    }

    function swapYesForNo(uint256 yesIn, uint256 minNoOut) external returns (uint256 noOut) {
        noOut = getAmountOut(yesIn, yesReserve, noReserve);

        require(noOut >= minNoOut, "Slippage exceeded");

        yesReserve += yesIn;

        noReserve -= noOut;
    }

    function swapNoForYes(uint256 noIn, uint256 minYesOut) external returns (uint256 yesOut) {
        yesOut = getAmountOut(noIn, noReserve, yesReserve);

        require(yesOut >= minYesOut, "Slippage exceeded");

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
