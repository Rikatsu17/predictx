// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MarketConfigV1.sol";

contract MarketConfigV2 is MarketConfigV1 {
    uint256 public maxOracleStaleness;

    event MaxOracleStalenessUpdated(uint256 oldStaleness, uint256 newStaleness);

    function setMaxOracleStaleness(uint256 newStaleness) external onlyOwner {
        require(newStaleness >= 5 minutes, "staleness too short");
        emit MaxOracleStalenessUpdated(maxOracleStaleness, newStaleness);
        maxOracleStaleness = newStaleness;
    }

    function version() external pure override returns (string memory) {
        return "2.0.0";
    }
}
