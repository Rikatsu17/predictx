// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {AssemblyMath} from "src/utils/AssemblyMath.sol";
import {FeeVault} from "src/vault/FeeVault.sol";
import {MarketConfigV1} from "src/upgrade/MarketConfigV1.sol";
import {MarketConfigV2} from "src/upgrade/MarketConfigV2.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";

contract CapstoneRequirementsTest is Test {
    PredictAIToken token;
    PredictAIOutcomeShares shares;
    OracleAdapter oracle;
    MarketFactory factory;
    FeeVault vault;
    AssemblyMath assemblyMath;
    address alice = address(0xA11CE);
    address treasury = address(0x7E45);

    function setUp() public {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
        oracle = new OracleAdapter(true);
        factory = new MarketFactory(address(shares), address(oracle));
        vault = new FeeVault(token, address(this));
        assemblyMath = new AssemblyMath();
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(factory));
        token.mint(alice, 1_000 ether);
    }

    function testFactoryCreate2DeploysMarket() public {
        address market = factory.createMarket("GPT-6 before 2027?", block.timestamp + 1 days, keccak256("gpt6"));
        assertEq(PredictionMarket(market).question(), "GPT-6 before 2027?");
    }

    function testFactoryCreateDeploysMarket() public {
        address market = factory.createMarketCreate("AGI before 2030?", block.timestamp + 1 days);
        assertEq(PredictionMarket(market).question(), "AGI before 2030?");
    }

    function testFactoryStoresMarketsFromBothCreateModes() public {
        factory.createMarket("NVIDIA above 300?", block.timestamp + 1 days, keccak256("nvda"));
        factory.createMarketCreate("Apple AR glasses?", block.timestamp + 1 days);
        assertEq(factory.getMarkets().length, 2);
    }

    function testFactoryCreate2DeterministicSaltCannotRepeat() public {
        bytes32 salt = keccak256("same");
        factory.createMarket("First", block.timestamp + 1 days, salt);
        vm.expectRevert();
        factory.createMarket("First", block.timestamp + 1 days, salt);
    }

    function testVaultDepositMintsShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        uint256 minted = vault.deposit(100 ether, alice);
        vm.stopPrank();
        assertEq(minted, 100 ether);
        assertEq(vault.balanceOf(alice), 100 ether);
    }

    function testVaultWithdrawBurnsShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, alice);
        uint256 burned = vault.withdraw(40 ether, alice, alice);
        vm.stopPrank();
        assertEq(burned, 40 ether);
        assertEq(vault.balanceOf(alice), 60 ether);
    }

    function testVaultPreviewDepositRounding() public view {
        assertEq(vault.previewDeposit(123 ether), 123 ether);
    }

    function testVaultPreviewMintRounding() public view {
        assertEq(vault.previewMint(55 ether), 55 ether);
    }

    function testVaultOwnerCanSweep() public {
        token.approve(address(vault), 100 ether);
        vault.deposit(100 ether, address(this));
        vault.sweep(treasury, 10 ether);
        assertEq(token.balanceOf(treasury), 10 ether);
    }

    function testVaultNonOwnerCannotSweep() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.sweep(alice, 1 ether);
    }

    function testUUPSInitializesV1() public {
        MarketConfigV1 config = _deployConfigV1();
        assertEq(config.treasury(), treasury);
        assertEq(config.disputeWindow(), 2 days);
        assertEq(config.version(), "1.0.0");
    }

    function testUUPSOwnerUpdatesFee() public {
        MarketConfigV1 config = _deployConfigV1();
        config.setMarketCreationFee(0.05 ether);
        assertEq(config.marketCreationFee(), 0.05 ether);
    }

    function testUUPSNonOwnerCannotUpdateFee() public {
        MarketConfigV1 config = _deployConfigV1();
        vm.prank(alice);
        vm.expectRevert();
        config.setMarketCreationFee(1 ether);
    }

    function testUUPSRejectsShortDisputeWindow() public {
        MarketConfigV1 config = _deployConfigV1();
        vm.expectRevert("window too short");
        config.setDisputeWindow(30 minutes);
    }

    function testUUPSOwnerUpdatesDisputeWindowAndTreasury() public {
        MarketConfigV1 config = _deployConfigV1();
        address newTreasury = address(0xBEEF);
        config.setDisputeWindow(3 days);
        config.setTreasury(newTreasury);
        assertEq(config.disputeWindow(), 3 days);
        assertEq(config.treasury(), newTreasury);
    }

    function testUUPSRejectsZeroTreasury() public {
        MarketConfigV1 config = _deployConfigV1();
        vm.expectRevert("treasury zero");
        config.setTreasury(address(0));
    }

    function testUUPSInitializeRejectsZeroTreasury() public {
        MarketConfigV1 implementation = new MarketConfigV1();
        bytes memory data = abi.encodeCall(MarketConfigV1.initialize, (address(this), address(0), 0.01 ether, 2 days));
        vm.expectRevert("treasury zero");
        new ERC1967Proxy(address(implementation), data);
    }

    function testUUPSV2UpgradePreservesStorage() public {
        MarketConfigV1 config = _deployConfigV1();
        MarketConfigV2 v2 = new MarketConfigV2();
        config.upgradeToAndCall(address(v2), "");
        MarketConfigV2 upgraded = MarketConfigV2(address(config));
        assertEq(upgraded.treasury(), treasury);
        assertEq(upgraded.version(), "2.0.0");
    }

    function testUUPSV2AddsOracleStaleness() public {
        MarketConfigV1 config = _deployConfigV1();
        MarketConfigV2 v2 = new MarketConfigV2();
        config.upgradeToAndCall(address(v2), "");
        MarketConfigV2(address(config)).setMaxOracleStaleness(1 hours);
        assertEq(MarketConfigV2(address(config)).maxOracleStaleness(), 1 hours);
    }

    function testAssemblyQuoteMatchesSolidity() public view {
        uint256 solidityQuote = assemblyMath.quoteSolidity(10 ether, 100 ether, 120 ether);
        uint256 yulQuote = assemblyMath.quoteYul(10 ether, 100 ether, 120 ether);
        assertEq(yulQuote, solidityQuote);
    }

    function testAssemblyQuoteRejectsZeroAmount() public {
        vm.expectRevert("amount zero");
        assemblyMath.quoteSolidity(0, 100, 100);
        vm.expectRevert("amount zero");
        assemblyMath.quoteYul(0, 100, 100);
    }

    function testAssemblyQuoteRejectsZeroLiquidity() public {
        vm.expectRevert("liquidity zero");
        assemblyMath.quoteSolidity(1, 0, 100);
        vm.expectRevert("liquidity zero");
        assemblyMath.quoteYul(1, 100, 0);
    }

    function testFuzzAssemblyQuoteMatchesSolidity(uint112 amountIn, uint112 reserveIn, uint112 reserveOut) public view {
        vm.assume(amountIn > 0 && reserveIn > 0 && reserveOut > 0);
        uint256 solidityQuote = assemblyMath.quoteSolidity(amountIn, reserveIn, reserveOut);
        uint256 yulQuote = assemblyMath.quoteYul(amountIn, reserveIn, reserveOut);
        assertEq(yulQuote, solidityQuote);
    }

    function testMarketRejectsSwapWithoutLiquidity() public {
        address market = factory.createMarket("OpenAI IPO?", block.timestamp + 1 days, keccak256("ipo"));
        vm.expectRevert("No liquidity");
        PredictionMarket(market).swapYesForNo(1 ether, 1);
    }

    function testMarketCreateEventCount() public {
        factory.createMarket("Meta AI glasses?", block.timestamp + 1 days, keccak256("meta"));
        address[] memory markets = factory.getMarkets();
        assertEq(markets.length, 1);
        assertTrue(markets[0] != address(0));
    }

    function testTokenPermitDomainExists() public view {
        assertEq(token.name(), "PredictAI Token");
    }

    function testOutcomeSharesSupportsERC1155Interface() public view {
        assertTrue(shares.supportsInterface(0xd9b67a26));
    }

    function testOutcomeSharesSetUriAndGrantMarketRole() public {
        address market = address(0xCAFE);
        shares.setURI("ipfs://predictx/");
        shares.grantMarketRole(market);
        assertTrue(shares.hasRole(shares.MARKET_ROLE(), market));
    }

    function _deployConfigV1() internal returns (MarketConfigV1) {
        MarketConfigV1 implementation = new MarketConfigV1();
        bytes memory data = abi.encodeCall(MarketConfigV1.initialize, (address(this), treasury, 0.01 ether, 2 days));
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);
        return MarketConfigV1(address(proxy));
    }
}
