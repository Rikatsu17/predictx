// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {MarketFactory} from "src/market/MarketFactory.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";

contract AdditionalCoverageTest is Test {
    PredictAIToken token;
    PredictAIOutcomeShares shares;
    OracleAdapter oracle;
    PredictionMarket market;
    MarketFactory factory;
    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
        oracle = new OracleAdapter(false);
        market = new PredictionMarket(address(shares), address(oracle), "GPT-6 before 2027?", block.timestamp + 1 days);
        factory = new MarketFactory(address(shares), address(oracle));
        shares.grantMarketRole(address(market));
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(factory));
    }

    function test01Question() public view {
        assertEq(market.question(), "GPT-6 before 2027?");
    }

    function test02EndTimeInFuture() public view {
        assertGt(market.endTime(), block.timestamp);
    }

    function test03FeeBps() public view {
        assertEq(market.FEE_BPS(), 30);
    }

    function test04BpsDenominator() public view {
        assertEq(market.BPS_DENOMINATOR(), 10000);
    }

    function test05YesId() public view {
        assertEq(market.YES(), 1);
    }

    function test06NoId() public view {
        assertEq(market.NO(), 2);
    }

    function test07InitialResolvedFalse() public view {
        assertFalse(market.resolved());
    }

    function test08InitialOracleOutcomeFalse() public view {
        assertFalse(oracle.outcome());
    }

    function test09OracleFreshInitially() public view {
        assertFalse(oracle.isStale());
    }

    function test10OracleThreshold() public view {
        assertEq(oracle.STALE_THRESHOLD(), 1 days);
    }

    function test11TokenSymbol() public view {
        assertEq(token.symbol(), "PAI");
    }

    function test12TokenDecimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test13TokenOwner() public view {
        assertEq(token.owner(), address(this));
    }

    function test14TokenVotesBeforeDelegateZero() public view {
        assertEq(token.getVotes(address(this)), 0);
    }

    function test15SharesAdminRole() public view {
        assertTrue(shares.hasRole(shares.DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function test16FactoryOutcomeShares() public view {
        assertEq(factory.outcomeShares(), address(shares));
    }

    function test17FactoryOracle() public view {
        assertEq(factory.oracle(), address(oracle));
    }

    function test18FactoryOwner() public view {
        assertEq(factory.owner(), address(this));
    }

    function test19FactoryMarketsInitiallyEmpty() public view {
        assertEq(factory.getMarkets().length, 0);
    }

    function test20BuyYesAfterEndReverts() public {
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("Market ended");
        market.buyYesShares(1);
    }

    function test21BuyNoAfterEndReverts() public {
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("Market ended");
        market.buyNoShares(1);
    }

    function test22ResolveBeforeEndReverts() public {
        vm.expectRevert("Market active");
        market.resolveMarket();
    }

    function test23ResolveWithStaleOracleReverts() public {
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert("Oracle stale");
        market.resolveMarket();
    }

    function test24CannotResolveTwice() public {
        vm.warp(block.timestamp + 1 days + 1);
        oracle.updateOutcome(true);
        market.resolveMarket();
        vm.expectRevert("Already resolved");
        market.resolveMarket();
    }

    function test25ProvideZeroLiquidityReverts() public {
        vm.expectRevert("Invalid liquidity");
        market.provideLiquidity(0, 10);
    }

    function test26SwapYesSlippageReverts() public {
        market.provideLiquidity(1000, 1000);
        vm.expectRevert("Slippage exceeded");
        market.swapYesForNo(100, 1000);
    }

    function test27SwapNoSlippageReverts() public {
        market.provideLiquidity(1000, 1000);
        vm.expectRevert("Slippage exceeded");
        market.swapNoForYes(100, 1000);
    }

    function test28SwapYesTooLargeReverts() public {
        market.provideLiquidity(1000, 1000);
        vm.expectRevert("swap too large");
        market.swapYesForNo(1000, 1);
    }

    function test29SwapNoTooLargeReverts() public {
        market.provideLiquidity(1000, 1000);
        vm.expectRevert("swap too large");
        market.swapNoForYes(1000, 1);
    }

    function test30OnlyOwnerUpdatesFactoryOracle() public {
        OracleAdapter newOracle = new OracleAdapter(true);
        factory.updateOracle(address(newOracle));
        assertEq(factory.oracle(), address(newOracle));
    }

    function test31NonOwnerCannotUpdateFactoryOracle() public {
        vm.prank(alice);
        vm.expectRevert();
        factory.updateOracle(address(123));
    }

    function test32DelegateCreatesVotes() public {
        token.transfer(alice, 10 ether);
        vm.prank(alice);
        token.delegate(alice);
        assertEq(token.getVotes(alice), 10 ether);
    }

    function test33TransfersMoveDelegatedVotes() public {
        token.transfer(alice, 10 ether);
        vm.prank(alice);
        token.delegate(alice);
        vm.prank(alice);
        token.transfer(bob, 4 ether);
        assertEq(token.getVotes(alice), 6 ether);
    }

    function test34FuzzProbability(uint96 yes, uint96 no) public {
        yes = uint96(bound(yes, 1, type(uint96).max));
        no = uint96(bound(no, 1, type(uint96).max));
        market.provideLiquidity(yes, no);
        uint256 probability = market.getYesProbability();
        assertLe(probability, 100);
    }
}
