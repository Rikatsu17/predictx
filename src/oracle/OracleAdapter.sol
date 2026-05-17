// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IOracleAdapter.sol";

contract OracleAdapter is IOracleAdapter {
    bool public outcome;
    uint256 public lastUpdated;
    uint256 public staleThreshold;

    constructor(bool initialOutcome) {
        outcome = initialOutcome;
        lastUpdated = block.timestamp;
        staleThreshold = 1 days;
    }

    function updateOutcome(bool newOutcome) external {
        outcome = newOutcome;
        lastUpdated = block.timestamp;
    }

    function updateStaleThreshold(uint256 newStaleThreshold) external {
        staleThreshold = newStaleThreshold;
    }

    function getOutcome() external view override returns (bool) {
        require(!isStale(), "oracle stale");
        return outcome;
    }

    function isStale() public view override returns (bool) {
        return block.timestamp > lastUpdated + staleThreshold;
    }
}
