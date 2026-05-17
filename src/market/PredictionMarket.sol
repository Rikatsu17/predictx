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
}
