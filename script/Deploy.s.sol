// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {PredictAITimelock} from "src/governance/Timelock.sol";
import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {FeeVault} from "src/vault/FeeVault.sol";
import {MarketConfigV1} from "src/upgrade/MarketConfigV1.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);

        PredictAIToken token = new PredictAIToken();
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();
        OracleAdapter oracle = new OracleAdapter(true);
        FeeVault vault = new FeeVault(token, deployer);

        address[] memory proposers = new address[](1);
        proposers[0] = address(0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        PredictAITimelock timelock = new PredictAITimelock(proposers, executors);
        PredictAIGovernor governor = new PredictAIGovernor(IVotes(address(token)), timelock);

        MarketFactory factory = new MarketFactory(address(shares), address(oracle));
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(factory));
        factory.transferOwnership(address(timelock));
        vault.transferOwnership(address(timelock));

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);

        MarketConfigV1 implementation = new MarketConfigV1();
        bytes memory initData =
            abi.encodeCall(MarketConfigV1.initialize, (address(timelock), address(vault), 0.01 ether, 2 days));
        ERC1967Proxy configProxy = new ERC1967Proxy(address(implementation), initData);

        factory.createMarket(
            "Will GPT-6 be released before 2027?", block.timestamp + 180 days, keccak256("PREDICTX_GPT6_2027")
        );
        factory.createMarketCreate("Will AGI be announced before 2030?", block.timestamp + 365 days);

        vm.stopBroadcast();

        console2.log("PredictAIToken", address(token));
        console2.log("OutcomeShares", address(shares));
        console2.log("OracleAdapter", address(oracle));
        console2.log("FeeVault", address(vault));
        console2.log("Timelock", address(timelock));
        console2.log("Governor", address(governor));
        console2.log("MarketFactory", address(factory));
        console2.log("MarketConfigProxy", address(configProxy));
        console2.log("MarketConfigImplementation", address(implementation));
    }
}
