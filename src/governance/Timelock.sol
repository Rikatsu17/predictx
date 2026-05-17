// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract PredictAITimelock is TimelockController {
    constructor(address[] memory proposers, address[] memory executors)
        TimelockController(2 days, proposers, executors, msg.sender)
    {}
}
