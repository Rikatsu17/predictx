// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IOracleAdapter.sol";
import "../interfaces/AggregatorV3Interface.sol";

contract ChainlinkOracleAdapter is IOracleAdapter {
    AggregatorV3Interface public immutable feed;
    int256 public immutable threshold;
    bool public immutable resolveAboveThreshold;
    uint256 public immutable staleThreshold;

    constructor(address feedAddress, int256 thresholdValue, bool resolveAbove, uint256 staleWindow) {
        require(feedAddress != address(0), "invalid feed");
        require(staleWindow > 0, "invalid stale window");

        feed = AggregatorV3Interface(feedAddress);
        threshold = thresholdValue;
        resolveAboveThreshold = resolveAbove;
        staleThreshold = staleWindow;
    }

    function getOutcome() external view override returns (bool) {
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        require(updatedAt > 0, "round incomplete");
        require(!isStale(), "oracle stale");

        return resolveAboveThreshold ? answer >= threshold : answer <= threshold;
    }

    function isStale() public view override returns (bool) {
        (, , , uint256 updatedAt,) = feed.latestRoundData();
        return updatedAt == 0 || block.timestamp > updatedAt + staleThreshold;
    }
}
