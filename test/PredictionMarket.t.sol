// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract PredictionMarketTest is Test {
    PredictAIToken token;
    PredictAIOutcomeShares shares;
    PredictionMarket market;
    OracleAdapter oracle;

    address feeVault = address(99);
    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
        oracle = new OracleAdapter(true);
        market = new PredictionMarket(
            address(token),
            address(shares),
            address(oracle),
            feeVault,
            "Will GPT-6 release before 2027?",
            block.timestamp + 1 days,
            1 days,
            address(this)
        );

        shares.grantMarketRole(address(market));
        token.transfer(alice, 10_000 ether);
        token.transfer(bob, 10_000 ether);

        vm.prank(alice);
        token.approve(address(market), type(uint256).max);
        vm.prank(bob);
        token.approve(address(market), type(uint256).max);
    }

    function testBuyYesSharesMintsOutcomeShares() public {
        vm.prank(alice);
        market.buyYesShares(100 ether);

        assertEq(shares.balanceOf(alice, market.yesTokenId()), 99.95 ether);
        assertEq(token.balanceOf(feeVault), 0.05 ether);
    }

    function testBuyNoSharesMintsOutcomeShares() public {
        vm.prank(alice);
        market.buyNoShares(50 ether);

        assertEq(shares.balanceOf(alice, market.noTokenId()), 49.975 ether);
    }

    function testBuyRevertsAfterMarketEnd() public {
        vm.warp(block.timestamp + 2 days);
        vm.prank(alice);
        vm.expectRevert("market ended");
        market.buyYesShares(1 ether);
    }

    function testProvideLiquidityMintsLpShares() public {
        _seedLiquidity(alice, 1000 ether);

        assertGt(market.yesReserve(), 0);
        assertGt(market.noReserve(), 0);
        assertGt(market.lpToken().balanceOf(alice), 0);
    }

    function testRemoveLiquidityReturnsShares() public {
        _seedLiquidity(alice, 1000 ether);
        uint256 lpBalance = market.lpToken().balanceOf(alice);

        vm.prank(alice);
        market.removeLiquidity(lpBalance / 2);

        assertGt(shares.balanceOf(alice, market.yesTokenId()), 0);
        assertGt(shares.balanceOf(alice, market.noTokenId()), 0);
    }

    function testSwapYesForNo() public {
        _seedLiquidity(alice, 1000 ether);
        vm.prank(bob);
        market.buyYesShares(100 ether);
        vm.prank(bob);
        shares.setApprovalForAll(address(market), true);

        uint256 balanceBefore = shares.balanceOf(bob, market.noTokenId());

        vm.prank(bob);
        uint256 noOut = market.swapYesForNo(50 ether, 1);

        assertGt(noOut, 0);
        assertGt(shares.balanceOf(bob, market.noTokenId()), balanceBefore);
    }

    function testSwapNoForYes() public {
        _seedLiquidity(alice, 1000 ether);
        vm.prank(bob);
        market.buyNoShares(100 ether);
        vm.prank(bob);
        shares.setApprovalForAll(address(market), true);

        vm.prank(bob);
        uint256 yesOut = market.swapNoForYes(50 ether, 1);

        assertGt(yesOut, 0);
    }

    function testResolveFinalizeAndClaimWinnings() public {
        vm.prank(alice);
        market.buyYesShares(100 ether);

        vm.warp(block.timestamp + 2 days);
        market.resolveMarket();
        vm.warp(block.timestamp + 1 days + 1);
        market.finalizeMarket();

        uint256 beforeBalance = token.balanceOf(alice);
        uint256 sharesBalance = shares.balanceOf(alice, market.yesTokenId());

        vm.prank(alice);
        market.claimWinnings(sharesBalance);

        assertEq(token.balanceOf(alice), beforeBalance + sharesBalance);
    }

    function testDisputeBlocksFinalize() public {
        vm.warp(block.timestamp + 2 days);
        market.resolveMarket();
        market.disputeMarket("oracle mismatch");
        vm.warp(block.timestamp + 1 days + 1);

        vm.expectRevert("market disputed");
        market.finalizeMarket();
    }

    function testPauseBlocksTrading() public {
        market.pause();
        vm.prank(alice);
        vm.expectRevert();
        market.buyYesShares(1 ether);
    }

    function testUpdateOracle() public {
        OracleAdapter newOracle = new OracleAdapter(false);
        market.updateOracle(address(newOracle));
        assertEq(address(market.oracle()), address(newOracle));
    }

    function testGetYesProbability() public {
        _seedLiquidity(alice, 1000 ether);
        assertEq(market.getYesProbability(), 50);
    }

    function _seedLiquidity(address provider, uint256 amount) internal {
        vm.startPrank(provider);
        market.buyYesShares(amount);
        market.buyNoShares(amount);
        shares.setApprovalForAll(address(market), true);
        market.provideLiquidity(
            shares.balanceOf(provider, market.yesTokenId()),
            shares.balanceOf(provider, market.noTokenId())
        );
        vm.stopPrank();
    }
}
