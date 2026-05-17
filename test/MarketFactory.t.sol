// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";

import {MarketFactory} from "src/market/MarketFactory.sol";

import {PredictionMarket} from "src/market/PredictionMarket.sol";

contract MarketFactoryTest is Test {
    PredictAIOutcomeShares shares;

    MarketFactory factory;

    address alice = address(1);

    function setUp() public {
        shares = new PredictAIOutcomeShares();

        factory = new MarketFactory(address(shares));
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(factory));
    }

    function testCreateMarket() public {
        bytes32 salt = keccak256("GPT6");

        address marketAddress = factory.createMarket("Will GPT-6 release before 2027?", block.timestamp + 1 days, salt);

        PredictionMarket market = PredictionMarket(marketAddress);

        assertEq(market.question(), "Will GPT-6 release before 2027?");
    }

    function testMarketCanMint() public {
        bytes32 salt = keccak256("AGI");

        address marketAddress = factory.createMarket("AGI before 2030?", block.timestamp + 1 days, salt);

        vm.prank(alice);

        PredictionMarket(marketAddress).buyYesShares(100);

        assertEq(shares.balanceOf(alice, 1), 100);
    }
}
