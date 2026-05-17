// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IOracleAdapter.sol";

contract OracleAdapter is IOracleAdapter {
    bool public outcome;

    uint256 public lastUpdated;

    uint256 public constant STALE_THRESHOLD = 1 days;

    constructor(bool _initialOutcome) {
        outcome = _initialOutcome;

        lastUpdated = block.timestamp;
    }

    function updateOutcome(bool newOutcome) external {
        outcome = newOutcome;

        lastUpdated = block.timestamp;
    }

    function getOutcome() external view override returns (bool) {
        require(!isStale(), "Oracle stale");

        return outcome;
    }

    function isStale() public view override returns (bool) {
        return block.timestamp > lastUpdated + STALE_THRESHOLD;
    }
}
