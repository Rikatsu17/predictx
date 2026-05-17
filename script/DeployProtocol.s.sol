// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {PredictionMarket} from "src/market/PredictionMarket.sol";
import {PredictAITimelock} from "src/governance/Timelock.sol";
import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract DeployProtocolScript is Script {
    struct Deployment {
        address token;
        address shares;
        address oracle;
        address marketFactory;
        address timelock;
        address governor;
        address initialMarket;
    }

    function run() external returns (Deployment memory deployed) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        string memory initialQuestion =
            vm.envOr("INITIAL_MARKET_QUESTION", string("Will GPT-6 release before 2027?"));
        uint256 initialEndTime = vm.envOr("INITIAL_MARKET_END_TIME", block.timestamp + 30 days);
        bool createInitialMarket = vm.envOr("CREATE_INITIAL_MARKET", true);
        bool initialOracleOutcome = vm.envOr("INITIAL_ORACLE_OUTCOME", true);
        bytes32 initialSalt = keccak256(bytes(vm.envOr("INITIAL_MARKET_SALT", string("PREDICTX_INITIAL_MARKET"))));

        vm.startBroadcast(deployerPrivateKey);

        PredictAIToken token = new PredictAIToken();
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();
        OracleAdapter oracle = new OracleAdapter(initialOracleOutcome);
        MarketFactory marketFactory = new MarketFactory(address(shares), address(oracle));

        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(marketFactory));

        address[] memory proposers = new address[](1);
        proposers[0] = address(0);

        address[] memory executors = new address[](1);
        executors[0] = address(0);

        PredictAITimelock timelock = new PredictAITimelock(proposers, executors);
        PredictAIGovernor governor = new PredictAIGovernor(IVotes(address(token)), timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        address initialMarket = address(0);
        if (createInitialMarket) {
            initialMarket = marketFactory.createMarket(initialQuestion, initialEndTime, initialSalt);
        }

        vm.stopBroadcast();

        deployed = Deployment({
            token: address(token),
            shares: address(shares),
            oracle: address(oracle),
            marketFactory: address(marketFactory),
            timelock: address(timelock),
            governor: address(governor),
            initialMarket: initialMarket
        });

        console2.log("Deployment complete for deployer:", deployer);
        console2.log("PredictAIToken:", deployed.token);
        console2.log("PredictAIOutcomeShares:", deployed.shares);
        console2.log("OracleAdapter:", deployed.oracle);
        console2.log("MarketFactory:", deployed.marketFactory);
        console2.log("PredictAITimelock:", deployed.timelock);
        console2.log("PredictAIGovernor:", deployed.governor);
        console2.log("Initial PredictionMarket:", deployed.initialMarket);

        console2.log("");
        console2.log("Frontend .env.local mapping:");
        console2.log("NEXT_PUBLIC_ARB_MARKET_FACTORY_ADDRESS=", deployed.marketFactory);
        console2.log("NEXT_PUBLIC_ARB_PREDICTAI_TOKEN_ADDRESS=", deployed.token);
        console2.log("NEXT_PUBLIC_ARB_PREDICTAI_GOVERNOR_ADDRESS=", deployed.governor);
        console2.log("NEXT_PUBLIC_ARB_TIMELOCK_ADDRESS=", deployed.timelock);
        console2.log("NEXT_PUBLIC_ARB_ORACLE_ADAPTER_ADDRESS=", deployed.oracle);
        console2.log("NEXT_PUBLIC_ARB_SHARES_ERC1155_ADDRESS=", deployed.shares);
        console2.log("NEXT_PUBLIC_ARB_PREDICTION_MARKET_ADDRESS=", deployed.initialMarket);
    }
}
