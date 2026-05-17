// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {ChainlinkOracleAdapter} from "src/oracle/ChainlinkOracleAdapter.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {PredictAITimelock} from "src/governance/Timelock.sol";
import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {PredictAITreasuryVault} from "src/vault/PredictAITreasuryVault.sol";

contract DeployProtocolScript is Script {
    struct Config {
        string initialQuestion;
        uint256 initialEndTime;
        uint256 defaultDisputeWindow;
        bool createInitialMarket;
        bool initialOracleOutcome;
        bool useChainlinkOracle;
        bytes32 initialSalt;
    }

    struct Deployment {
        address token;
        address shares;
        address oracle;
        address vaultImplementation;
        address vaultProxy;
        address marketFactory;
        address timelock;
        address governor;
        address initialMarket;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        Config memory config = _loadConfig();

        vm.startBroadcast(deployerPrivateKey);
        Deployment memory deployed = _deploy(config, deployer);
        vm.stopBroadcast();

        _logDeployment(deployer, deployed);
    }

    function _loadConfig() internal view returns (Config memory config) {
        config.initialQuestion = vm.envOr("INITIAL_MARKET_QUESTION", string("Will GPT-6 release before 2027?"));
        config.initialEndTime = vm.envOr("INITIAL_MARKET_END_TIME", block.timestamp + 30 days);
        config.defaultDisputeWindow = vm.envOr("DEFAULT_DISPUTE_WINDOW", uint256(2 days));
        config.createInitialMarket = vm.envOr("CREATE_INITIAL_MARKET", true);
        config.initialOracleOutcome = vm.envOr("INITIAL_ORACLE_OUTCOME", true);
        config.useChainlinkOracle = vm.envOr("USE_CHAINLINK_ORACLE", false);
        config.initialSalt = keccak256(bytes(vm.envOr("INITIAL_MARKET_SALT", string("PREDICTX_INITIAL_MARKET"))));
    }

    function _deploy(Config memory config, address deployer) internal returns (Deployment memory deployed) {
        PredictAIToken token = new PredictAIToken();
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();

        address[] memory proposers = new address[](1);
        proposers[0] = address(0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);

        PredictAITimelock timelock = new PredictAITimelock(proposers, executors);
        PredictAIGovernor governor = new PredictAIGovernor(IVotes(address(token)), timelock);
        PredictAITreasuryVault vaultImplementation = new PredictAITreasuryVault();
        ERC1967Proxy vaultProxy = new ERC1967Proxy(
            address(vaultImplementation),
            abi.encodeCall(PredictAITreasuryVault.initialize, (address(token), address(timelock)))
        );
        address oracleAddress = _deployOracle(config);

        MarketFactory marketFactory = new MarketFactory(
            address(token),
            address(shares),
            oracleAddress,
            address(vaultProxy),
            config.defaultDisputeWindow
        );

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        token.transferOwnership(address(timelock));
        marketFactory.transferOwnership(address(timelock));

        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(marketFactory));
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(timelock));
        shares.renounceRole(shares.DEFAULT_ADMIN_ROLE(), deployer);

        address initialMarket = address(0);
        if (config.createInitialMarket) {
          initialMarket = marketFactory.createMarket(config.initialQuestion, config.initialEndTime, config.initialSalt);
        }

        deployed = Deployment({
            token: address(token),
            shares: address(shares),
            oracle: oracleAddress,
            vaultImplementation: address(vaultImplementation),
            vaultProxy: address(vaultProxy),
            marketFactory: address(marketFactory),
            timelock: address(timelock),
            governor: address(governor),
            initialMarket: initialMarket
        });
    }

    function _deployOracle(Config memory config) internal returns (address oracleAddress) {
        if (config.useChainlinkOracle) {
            address feed = vm.envAddress("CHAINLINK_FEED");
            int256 threshold = vm.envInt("CHAINLINK_THRESHOLD");
            bool resolveAbove = vm.envOr("CHAINLINK_RESOLVE_ABOVE", true);
            uint256 staleWindow = vm.envOr("CHAINLINK_STALE_WINDOW", uint256(1 days));
            return address(new ChainlinkOracleAdapter(feed, threshold, resolveAbove, staleWindow));
        }

        return address(new OracleAdapter(config.initialOracleOutcome));
    }

    function _logDeployment(address deployer, Deployment memory deployed) internal view {
        console2.log("Deployment complete for deployer:", deployer);
        console2.log("PredictAIToken:", deployed.token);
        console2.log("PredictAIOutcomeShares:", deployed.shares);
        console2.log("OracleAdapter:", deployed.oracle);
        console2.log("PredictAITreasuryVault implementation:", deployed.vaultImplementation);
        console2.log("PredictAITreasuryVault proxy:", deployed.vaultProxy);
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
