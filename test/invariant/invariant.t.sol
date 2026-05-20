// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "forge-std/StdInvariant.sol";

import {PredictionMarket} from "src/market/PredictionMarket.sol";

import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";

import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {FeeVault} from "src/vault/FeeVault.sol";

contract InvariantHandler is Test {
    PredictionMarket public market;
    PredictAIToken public token;
    FeeVault public vault;

    uint256 public initialK;
    uint256 public initialTokenSupply;
    uint256 public successfulSwaps;
    uint256 public successfulDeposits;
    uint256 public successfulWithdrawals;

    constructor(PredictionMarket market_, PredictAIToken token_, FeeVault vault_) {
        market = market_;
        token = token_;
        vault = vault_;
        initialK = market_.yesReserve() * market_.noReserve();
        initialTokenSupply = token_.totalSupply();
        token_.approve(address(vault_), type(uint256).max);
    }

    function swapYesForNo(uint256 amountIn) public {
        uint256 reserve = market.yesReserve();
        if (reserve <= 2 || market.noReserve() <= 2) return;
        amountIn = bound(amountIn, 1, reserve / 2);
        try market.swapYesForNo(amountIn, 1) returns (uint256 amountOut) {
            if (amountOut > 0) successfulSwaps++;
        } catch {}
    }

    function swapNoForYes(uint256 amountIn) public {
        uint256 reserve = market.noReserve();
        if (reserve <= 2 || market.yesReserve() <= 2) return;
        amountIn = bound(amountIn, 1, reserve / 2);
        try market.swapNoForYes(amountIn, 1) returns (uint256 amountOut) {
            if (amountOut > 0) successfulSwaps++;
        } catch {}
    }

    function deposit(uint256 assets) public {
        assets = bound(assets, 1, 1_000 ether);
        if (token.balanceOf(address(this)) < assets) return;
        try vault.deposit(assets, address(this)) returns (uint256 shares) {
            if (shares > 0) successfulDeposits++;
        } catch {}
    }

    function withdraw(uint256 assets) public {
        uint256 maxAssets = vault.maxWithdraw(address(this));
        if (maxAssets == 0) return;
        assets = bound(assets, 1, maxAssets);
        try vault.withdraw(assets, address(this), address(this)) returns (uint256 shares) {
            if (shares > 0) successfulWithdrawals++;
        } catch {}
    }
}

contract InvariantTest is StdInvariant, Test {
    PredictionMarket market;
    PredictAIToken token;
    FeeVault vault;
    InvariantHandler handler;

    function setUp() public {
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();

        OracleAdapter oracle = new OracleAdapter(true);

        market = new PredictionMarket(address(shares), address(oracle), "AGI before 2030?", block.timestamp + 1 days);

        shares.grantRole(shares.MARKET_ROLE(), address(market));

        market.provideLiquidity(1_000_000, 1_000_000);

        token = new PredictAIToken();
        vault = new FeeVault(token, address(this));
        handler = new InvariantHandler(market, token, vault);
        token.mint(address(handler), 10_000 ether);

        targetContract(address(handler));
    }

    function invariantReservesNeverZero() public view {
        uint256 yesReserve = market.yesReserve();

        uint256 noReserve = market.noReserve();

        assertGt(yesReserve, 0);

        assertGt(noReserve, 0);
    }

    function invariantConstantProductNeverDecreases() public view {
        uint256 yesReserve = market.yesReserve();

        uint256 noReserve = market.noReserve();

        assertGt(yesReserve, 0);
        assertGt(noReserve, 0);

        uint256 currentK = yesReserve * noReserve;
        assertGe(currentK + 1, handler.initialK());
    }

    function invariantTotalSupplyConserved() public view {
        assertEq(token.totalSupply(), handler.initialTokenSupply() + 10_000 ether);
    }

    function invariantTreasuryAccountingMatchesAssets() public view {
        assertEq(vault.totalAssets(), token.balanceOf(address(vault)));
    }

    function invariantVaultSharesBackedByAssets() public view {
        assertLe(vault.convertToAssets(vault.totalSupply()), vault.totalAssets());
    }
}
