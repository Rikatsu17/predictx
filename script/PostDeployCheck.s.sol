// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {MarketFactory} from "src/market/MarketFactory.sol";
import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {PredictAITimelock} from "src/governance/Timelock.sol";

contract PostDeployCheck is Script {
    function run() external view {
        MarketFactory factory = MarketFactory(vm.envAddress("MARKET_FACTORY"));
        PredictAITimelock timelock = PredictAITimelock(payable(vm.envAddress("TIMELOCK")));
        PredictAIGovernor governor = PredictAIGovernor(payable(vm.envAddress("GOVERNOR")));

        require(factory.owner() == address(timelock), "factory owner is not timelock");
        require(timelock.getMinDelay() == 2 days, "bad timelock delay");
        require(governor.votingDelay() == 1, "bad voting delay");
        require(governor.votingPeriod() == 50400, "bad voting period");
        require(governor.proposalThreshold() == 1 ether, "bad proposal threshold");
        require(timelock.hasRole(timelock.PROPOSER_ROLE(), address(governor)), "governor not proposer");

        console2.log("Post-deployment checks passed");
    }
}
