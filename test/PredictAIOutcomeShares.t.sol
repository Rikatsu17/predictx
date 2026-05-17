// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {
    PredictAIOutcomeShares
}
from "src/token/PredictAIOutcomeShares.sol";

contract PredictAIOutcomeSharesTest is Test {

    PredictAIOutcomeShares shares;

    address market = address(1);

    address alice = address(2);

    uint256 constant YES_TOKEN = 1;

    function setUp() public {

        shares = new PredictAIOutcomeShares();

        shares.grantRole(
            shares.MARKET_ROLE(),
            market
        );
    }

    function testMintShares() public {

        vm.prank(market);

        shares.mint(
            alice,
            YES_TOKEN,
            100
        );

        assertEq(
            shares.balanceOf(
                alice,
                YES_TOKEN
            ),
            100
        );
    }

    function testBurnShares() public {

        vm.startPrank(market);

        shares.mint(
            alice,
            YES_TOKEN,
            100
        );

        shares.burn(
            alice,
            YES_TOKEN,
            50
        );

        vm.stopPrank();

        assertEq(
            shares.balanceOf(
                alice,
                YES_TOKEN
            ),
            50
        );
    }

    function testUnauthorizedMintReverts() public {

        vm.expectRevert();

        shares.mint(
            alice,
            YES_TOKEN,
            100
        );
    }
}