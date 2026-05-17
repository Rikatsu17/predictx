// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {ChainlinkOracleAdapter} from "src/oracle/ChainlinkOracleAdapter.sol";
import {MockAggregatorV3} from "src/oracle/MockAggregatorV3.sol";

contract OracleAdapterTest is Test {
    OracleAdapter oracle;
    MockAggregatorV3 feed;

    function setUp() public {
        oracle = new OracleAdapter(true);
        feed = new MockAggregatorV3(8, 3000e8);
    }

    function testInitialOutcome() public view {
        assertEq(oracle.getOutcome(), true);
    }

    function testUpdateOutcome() public {
        oracle.updateOutcome(false);
        assertEq(oracle.getOutcome(), false);
    }

    function testStaleOracleReverts() public {
        oracle.updateStaleThreshold(1);
        vm.warp(block.timestamp + 2);
        vm.expectRevert("oracle stale");
        oracle.getOutcome();
    }

    function testChainlinkOracleAboveThreshold() public {
        ChainlinkOracleAdapter adapter = new ChainlinkOracleAdapter(address(feed), 2500e8, true, 1 days);
        assertEq(adapter.getOutcome(), true);
    }

    function testChainlinkOracleBelowThreshold() public {
        ChainlinkOracleAdapter adapter = new ChainlinkOracleAdapter(address(feed), 3500e8, false, 1 days);
        assertEq(adapter.getOutcome(), true);
    }

    function testChainlinkStaleCheck() public {
        ChainlinkOracleAdapter adapter = new ChainlinkOracleAdapter(address(feed), 2500e8, true, 1);
        vm.warp(block.timestamp + 2);
        vm.expectRevert("oracle stale");
        adapter.getOutcome();
    }
}
