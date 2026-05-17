// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAITreasuryVault} from "src/vault/PredictAITreasuryVault.sol";
import {PredictAITreasuryVaultV2} from "src/vault/PredictAITreasuryVaultV2.sol";

contract PredictAITreasuryVaultTest is Test {
    PredictAIToken token;
    PredictAITreasuryVault implementation;
    PredictAITreasuryVault vault;
    address alice = address(1);

    function setUp() public {
        token = new PredictAIToken();
        implementation = new PredictAITreasuryVault();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(PredictAITreasuryVault.initialize, (address(token), address(this)))
        );
        vault = PredictAITreasuryVault(address(proxy));

        token.transfer(alice, 1_000 ether);
        vm.prank(alice);
        token.approve(address(vault), type(uint256).max);
    }

    function testDepositAndWithdraw() public {
        vm.prank(alice);
        vault.deposit(100 ether, alice);

        assertEq(vault.balanceOf(alice), 100 ether);

        vm.prank(alice);
        vault.withdraw(50 ether, alice, alice);

        assertEq(vault.balanceOf(alice), 50 ether);
    }

    function testUUPSUpgradePath() public {
        PredictAITreasuryVaultV2 implementationV2 = new PredictAITreasuryVaultV2();
        vault.upgradeToAndCall(address(implementationV2), "");

        assertEq(PredictAITreasuryVaultV2(address(vault)).version(), 2);
    }
}
