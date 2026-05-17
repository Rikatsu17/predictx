// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";

import {PredictionMarket} from "src/market/PredictionMarket.sol";

contract PredictionMarketTest is Test {
    PredictAIOutcomeShares shares;

    PredictionMarket market;

    address alice = address(1);

    function setUp() public {
        shares = new PredictAIOutcomeShares();

        market = new PredictionMarket(address(shares), "Will GPT-6 release before 2027?", block.timestamp + 1 days);

        shares.grantRole(shares.MARKET_ROLE(), address(market));
    }

    function testBuyYesShares() public {
        vm.prank(alice);

        market.buyYesShares(100);

        assertEq(shares.balanceOf(alice, 1), 100);
    }

    function testBuyNoShares() public {
        vm.prank(alice);

        market.buyNoShares(50);

        assertEq(shares.balanceOf(alice, 2), 50);
    }

    function testResolveMarket() public {
        vm.warp(block.timestamp + 2 days);

        market.resolveMarket(true);

        assertEq(market.resolved(), true);

        assertEq(market.outcome(), true);
    }

    function testProvideLiquidity() public {
        market.provideLiquidity(1000, 1000);

        assertEq(market.yesReserve(), 1000);

        assertEq(market.noReserve(), 1000);
    }

    function testSwapYesForNo() public {
        market.provideLiquidity(1000, 1000);

        uint256 noOut = market.swapYesForNo(100, 1);

        assertGt(noOut, 0);

        assertEq(market.yesReserve(), 1100);
    }

    function testProbability() public {
        market.provideLiquidity(900, 100);

        uint256 probability = market.getYesProbability();

        assertEq(probability, 90);
    }
}
