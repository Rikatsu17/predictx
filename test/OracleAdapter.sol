// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract OracleAdapterTest is Test {
    OracleAdapter oracle;

    function setUp() public {
        oracle = new OracleAdapter(true);
    }

    function testInitialOutcome() public {
        assertEq(oracle.getOutcome(), true);
    }

    function testUpdateOutcome() public {
        oracle.updateOutcome(false);

        assertEq(oracle.getOutcome(), false);
    }

    function testStaleOracleReverts() public {
        vm.warp(block.timestamp + 2 days);

        vm.expectRevert();

        oracle.getOutcome();
    }
}
