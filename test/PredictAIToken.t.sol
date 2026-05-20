// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract PredictAITokenTest is Test {
    PredictAIToken token;
    OracleAdapter oracle;
    PredictAIOutcomeShares shares;
    PredictionMarket market;
    address alice = address(1);

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();

        oracle = new OracleAdapter(true);

        market = new PredictionMarket(
            address(shares), address(oracle), "Will GPT-6 release before 2027?", block.timestamp + 1 days
        );

        shares.grantRole(shares.MARKET_ROLE(), address(market));
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1_000_000 ether);
    }

    function testMint() public {
        token.mint(alice, 100 ether);

        assertEq(token.balanceOf(alice), 100 ether);
    }

    function testVotingPower() public {
        token.transfer(alice, 100 ether);

        vm.prank(alice);

        token.delegate(alice);

        assertEq(token.getVotes(alice), 100 ether);
    }

    function testNonceStartsAtZero() public view {
        assertEq(token.nonces(address(this)), 0);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1 ether);
    }
}
