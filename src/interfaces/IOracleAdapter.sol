// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOracleAdapter {
    function getOutcome() external view returns (bool);

    function isStale() external view returns (bool);
}
