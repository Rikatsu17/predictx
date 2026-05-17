// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract InvariantTest is StdInvariant, Test {
    PredictionMarket market;
    PredictAIToken token;
    PredictAIOutcomeShares shares;

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
        OracleAdapter oracle = new OracleAdapter(true);

        market = new PredictionMarket(
            address(token),
            address(shares),
            address(oracle),
            address(77),
            "AGI before 2030?",
            block.timestamp + 30 days,
            1 days,
            address(this)
        );

        shares.grantMarketRole(address(market));
        token.approve(address(market), type(uint256).max);
        market.buyYesShares(1_000 ether);
        market.buyNoShares(1_000 ether);
        shares.setApprovalForAll(address(market), true);
        market.provideLiquidity(shares.balanceOf(address(this), market.yesTokenId()), shares.balanceOf(address(this), market.noTokenId()));

        targetContract(address(market));
    }

    function invariantReservesBackedByMarketBalances() public view {
        assertEq(shares.balanceOf(address(market), market.yesTokenId()), market.yesReserve());
        assertEq(shares.balanceOf(address(market), market.noTokenId()), market.noReserve());
    }

    function invariantLpSupplyExistsWhenLiquidityExists() public view {
        if (market.yesReserve() > 0 && market.noReserve() > 0) {
            assertGt(market.lpToken().totalSupply(), 0);
        }
    }
}
