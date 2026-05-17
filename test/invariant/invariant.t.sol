// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "forge-std/StdInvariant.sol";

import {PredictionMarket} from "src/market/PredictionMarket.sol";

import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract InvariantTest is StdInvariant, Test {
    PredictionMarket market;

    function setUp() public {
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();

        OracleAdapter oracle = new OracleAdapter(true);

        market = new PredictionMarket(address(shares), address(oracle), "AGI before 2030?", block.timestamp + 1 days);

        shares.grantRole(shares.MARKET_ROLE(), address(market));

        market.provideLiquidity(1000, 1000);

        targetContract(address(market));
    }

    function invariantReservesNeverZero() public view {
        uint256 yesReserve = market.yesReserve();

        uint256 noReserve = market.noReserve();

        assertGt(yesReserve, 0);

        assertGt(noReserve, 0);
    }

    function invariantConstantProduct() public view {
        uint256 yesReserve = market.yesReserve();

        uint256 noReserve = market.noReserve();

        assertGt(yesReserve, 0);
        assertGt(noReserve, 0);

        (uint256 high, uint256 low) = Math.mul512(yesReserve, noReserve);
        assertTrue(high > 0 || low > 0);
    }
}
