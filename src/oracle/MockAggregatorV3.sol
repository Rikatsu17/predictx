// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/AggregatorV3Interface.sol";

contract MockAggregatorV3 is AggregatorV3Interface {
    uint8 public immutable override decimals;
    int256 public answer;
    uint256 public updatedAt;

    constructor(uint8 decimals_, int256 initialAnswer) {
        decimals = decimals_;
        answer = initialAnswer;
        updatedAt = block.timestamp;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256, uint256 startedAt, uint256, uint80 answeredInRound)
    {
        return (1, answer, updatedAt, updatedAt, 1);
    }

    function updateAnswer(int256 newAnswer) external {
        answer = newAnswer;
        updatedAt = block.timestamp;
    }
}
