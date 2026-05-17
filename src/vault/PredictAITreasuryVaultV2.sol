// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PredictAITreasuryVault.sol";

contract PredictAITreasuryVaultV2 is PredictAITreasuryVault {
    function version() external pure override returns (uint256) {
        return 2;
    }
}
