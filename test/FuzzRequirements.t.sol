// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {FeeVault} from "src/vault/FeeVault.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";

contract FuzzRequirementsTest is Test {
    PredictAIOutcomeShares shares;
    OracleAdapter oracle;
    PredictionMarket market;
    PredictAIToken token;
    FeeVault vault;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        shares = new PredictAIOutcomeShares();
        oracle = new OracleAdapter(true);
        market = new PredictionMarket(address(shares), address(oracle), "Will ETH outperform BTC?", block.timestamp + 30 days);
        shares.grantRole(shares.MARKET_ROLE(), address(market));

        token = new PredictAIToken();
        vault = new FeeVault(token, address(this));
        token.mint(alice, 1_000_000 ether);
        token.mint(bob, 1_000_000 ether);
    }

    function testFuzzSwapYesForNoKeepsK(uint128 liquidity, uint128 amountIn) public {
        liquidity = uint128(bound(liquidity, 1_000, 1e24));
        amountIn = uint128(bound(amountIn, 1, liquidity - 1));
        market.provideLiquidity(liquidity, liquidity);

        uint256 beforeK = market.yesReserve() * market.noReserve();
        uint256 noOut = market.swapYesForNo(amountIn, 1);

        assertGt(noOut, 0);
        assertGe(market.yesReserve() * market.noReserve() + 1, beforeK);
    }

    function testFuzzSwapNoForYesKeepsK(uint128 liquidity, uint128 amountIn) public {
        liquidity = uint128(bound(liquidity, 1_000, 1e24));
        amountIn = uint128(bound(amountIn, 1, liquidity - 1));
        market.provideLiquidity(liquidity, liquidity);

        uint256 beforeK = market.yesReserve() * market.noReserve();
        uint256 yesOut = market.swapNoForYes(amountIn, 1);

        assertGt(yesOut, 0);
        assertGe(market.yesReserve() * market.noReserve() + 1, beforeK);
    }

    function testFuzzAmountOutIsBounded(uint128 amountIn, uint128 reserveIn, uint128 reserveOut) public view {
        amountIn = uint128(bound(amountIn, 1, 1e24));
        reserveIn = uint128(bound(reserveIn, 1, 1e24));
        reserveOut = uint128(bound(reserveOut, 2, 1e24));

        uint256 amountOut = market.getAmountOut(amountIn, reserveIn, reserveOut);

        assertGt(amountOut, 0);
        assertLt(amountOut, reserveOut);
    }

    function testFuzzBuyYesSharesMintsExactBalance(uint128 amount) public {
        amount = uint128(bound(amount, 1, 1e30));

        vm.prank(alice);
        market.buyYesShares(amount);

        assertEq(shares.balanceOf(alice, market.YES()), amount);
        assertEq(market.totalYesShares(), amount);
    }

    function testFuzzBuyNoSharesMintsExactBalance(uint128 amount) public {
        amount = uint128(bound(amount, 1, 1e30));

        vm.prank(bob);
        market.buyNoShares(amount);

        assertEq(shares.balanceOf(bob, market.NO()), amount);
        assertEq(market.totalNoShares(), amount);
    }

    function testFuzzVaultDepositAccounting(uint128 assets) public {
        assets = uint128(bound(assets, 1, 1_000_000 ether));

        vm.startPrank(alice);
        token.approve(address(vault), assets);
        uint256 sharesMinted = vault.deposit(assets, alice);
        vm.stopPrank();

        assertEq(sharesMinted, assets);
        assertEq(vault.totalAssets(), assets);
        assertEq(token.balanceOf(address(vault)), assets);
    }

    function testFuzzVaultWithdrawAccounting(uint128 depositAssets, uint128 withdrawAssets) public {
        depositAssets = uint128(bound(depositAssets, 2, 1_000_000 ether));
        withdrawAssets = uint128(bound(withdrawAssets, 1, depositAssets));

        vm.startPrank(alice);
        token.approve(address(vault), depositAssets);
        vault.deposit(depositAssets, alice);
        uint256 sharesBurned = vault.withdraw(withdrawAssets, alice, alice);
        vm.stopPrank();

        assertEq(sharesBurned, withdrawAssets);
        assertEq(vault.totalAssets(), depositAssets - withdrawAssets);
        assertEq(token.balanceOf(address(vault)), depositAssets - withdrawAssets);
    }

    function testFuzzVotingPowerAfterDelegate(uint128 amount) public {
        amount = uint128(bound(amount, 1, 1_000_000 ether));

        token.transfer(alice, amount);
        vm.prank(alice);
        token.delegate(alice);

        assertEq(token.getVotes(alice), token.balanceOf(alice));
    }

    function testFuzzVotingPowerMovesWithDelegatedTransfer(uint128 amount, uint128 transferAmount) public {
        amount = uint128(bound(amount, 2, 1_000_000 ether));
        transferAmount = uint128(bound(transferAmount, 1, amount - 1));

        token.transfer(alice, amount);
        vm.prank(alice);
        token.delegate(alice);
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        assertEq(token.getVotes(alice), token.balanceOf(alice));
        assertEq(token.getVotes(bob), 0);
    }

    function testFuzzVotingPowerReceiverCanDelegate(uint128 amount, uint128 transferAmount) public {
        amount = uint128(bound(amount, 2, 1_000_000 ether));
        transferAmount = uint128(bound(transferAmount, 1, amount - 1));

        token.transfer(alice, amount);
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        vm.prank(bob);
        token.delegate(bob);

        assertEq(token.getVotes(bob), token.balanceOf(bob));
    }
}
