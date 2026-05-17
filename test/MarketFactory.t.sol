// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract MarketFactoryTest is Test {
    PredictAIToken token;
    PredictAIOutcomeShares shares;
    MarketFactory factory;
    OracleAdapter oracle;

    address feeVault = address(88);

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
        oracle = new OracleAdapter(true);
        factory = new MarketFactory(address(token), address(shares), address(oracle), feeVault, 1 days);

        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(factory));
    }

    function testCreateMarketDeterministic() public {
        bytes32 salt = keccak256("GPT6");
        address marketAddress = factory.createMarket("Will GPT-6 release before 2027?", block.timestamp + 7 days, salt);

        assertEq(factory.getMarkets().length, 1);
        assertEq(PredictionMarket(marketAddress).question(), "Will GPT-6 release before 2027?");
    }

    function testCreateMarketWithCreate() public {
        address marketAddress = factory.createMarketWithCreate("AGI before 2030?", block.timestamp + 7 days);

        assertEq(factory.getMarkets().length, 1);
        assertEq(PredictionMarket(marketAddress).question(), "AGI before 2030?");
    }

    function testCreateMarketWithOracle() public {
        OracleAdapter customOracle = new OracleAdapter(false);
        bytes32 salt = keccak256("Custom");
        address marketAddress = factory.createMarketWithOracle("Custom", block.timestamp + 7 days, salt, address(customOracle));

        assertEq(address(PredictionMarket(marketAddress).oracle()), address(customOracle));
    }

    function testUpdateOracle() public {
        OracleAdapter newOracle = new OracleAdapter(false);
        factory.updateOracle(address(newOracle));

        assertEq(factory.defaultOracle(), address(newOracle));
    }
}
