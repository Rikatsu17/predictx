// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";
import {PredictAIOutcomeShares} from "src/token/PredictAIOutcomeShares.sol";
import {OracleAdapter} from "src/oracle/OracleAdapter.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";
import {PredictAITimelock} from "src/governance/Timelock.sol";
import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {FeeVault} from "src/vault/FeeVault.sol";

contract DeployProtocolScript is Script {
    address private _deployer;

    function _configureSharesRoles(
        PredictAIOutcomeShares shares,
        MarketFactory marketFactory,
        PredictAITimelock timelock
    ) internal {
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(marketFactory));
        shares.grantRole(shares.DEFAULT_ADMIN_ROLE(), address(timelock));
        shares.renounceRole(shares.DEFAULT_ADMIN_ROLE(), _deployer);
    }

    function _deployTokenAndShares()
        internal
        returns (PredictAIToken token, PredictAIOutcomeShares shares)
    {
        token = new PredictAIToken();
        shares = new PredictAIOutcomeShares();
    }

    function _deployTimelockGovernorVault(PredictAIToken token)
        internal
        returns (PredictAITimelock timelock, address governor, address vault)
    {
        address[] memory proposers = new address[](1);
        proposers[0] = address(0);

        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new PredictAITimelock(proposers, executors);
        governor = address(new PredictAIGovernor(IVotes(address(token)), timelock));
        vault = address(new FeeVault(token, address(timelock)));
    }

    function _deployOracleAndFactory(
        PredictAIOutcomeShares shares,
        bool initialOracleOutcome
    ) internal returns (address oracleAddress, MarketFactory marketFactory) {
        oracleAddress = address(new OracleAdapter(initialOracleOutcome));
        marketFactory = new MarketFactory(address(shares), oracleAddress);
    }

    function _createInitialMarket(
        MarketFactory marketFactory,
        string memory initialQuestion,
        uint256 initialEndTime,
        bytes32 initialSalt,
        bool createInitialMarket
    ) internal returns (address initialMarket) {
        if (createInitialMarket) {
            initialMarket = marketFactory.createMarket(initialQuestion, initialEndTime, initialSalt);
        } else {
            initialMarket = address(0);
        }
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        _deployer = vm.addr(deployerPrivateKey);

        string memory initialQuestion =
            vm.envOr("INITIAL_MARKET_QUESTION", string("Will GPT-6 release before 2027?"));
        uint256 initialEndTime = vm.envOr("INITIAL_MARKET_END_TIME", block.timestamp + 30 days);
        bool createInitialMarket = vm.envOr("CREATE_INITIAL_MARKET", true);
        bool initialOracleOutcome = vm.envOr("INITIAL_ORACLE_OUTCOME", true);
        bytes32 initialSalt = keccak256(bytes(vm.envOr("INITIAL_MARKET_SALT", string("PREDICTX_INITIAL_MARKET"))));

        vm.startBroadcast(deployerPrivateKey);

        address tokenAddress = address(new PredictAIToken());
        PredictAIOutcomeShares shares = new PredictAIOutcomeShares();
        (PredictAITimelock timelock, address governorAddress, address vaultAddress) = _deployTimelockGovernorVault(PredictAIToken(tokenAddress));
        (address oracleAddress, MarketFactory marketFactory) = _deployOracleAndFactory(shares, initialOracleOutcome);

        timelock.grantRole(timelock.PROPOSER_ROLE(), governorAddress);
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        PredictAIToken(tokenAddress).transferOwnership(address(timelock));
        marketFactory.transferOwnership(address(timelock));

        _configureSharesRoles(shares, marketFactory, timelock);

        address initialMarket = _createInitialMarket(
            marketFactory,
            initialQuestion,
            initialEndTime,
            initialSalt,
            createInitialMarket
        );

        vm.stopBroadcast();

        console2.log("Deployment complete for deployer:", _deployer);
        console2.log("PredictAIToken:", tokenAddress);
        console2.log("PredictAIOutcomeShares:", address(shares));
        console2.log("OracleAdapter:", oracleAddress);
        console2.log("FeeVault:", vaultAddress);
        console2.log("MarketFactory:", address(marketFactory));
        console2.log("PredictAITimelock:", address(timelock));
        console2.log("PredictAIGovernor:", governorAddress);
        console2.log("Initial PredictionMarket:", initialMarket);

        console2.log("");
        console2.log("Frontend .env.local mapping:");
        console2.log("NEXT_PUBLIC_ARB_MARKET_FACTORY_ADDRESS=", address(marketFactory));
        console2.log("NEXT_PUBLIC_ARB_PREDICTAI_TOKEN_ADDRESS=", tokenAddress);
        console2.log("NEXT_PUBLIC_ARB_PREDICTAI_GOVERNOR_ADDRESS=", governorAddress);
        console2.log("NEXT_PUBLIC_ARB_TIMELOCK_ADDRESS=", address(timelock));
        console2.log("NEXT_PUBLIC_ARB_ORACLE_ADAPTER_ADDRESS=", oracleAddress);
        console2.log("NEXT_PUBLIC_ARB_SHARES_ERC1155_ADDRESS=", address(shares));
        console2.log("NEXT_PUBLIC_ARB_PREDICTION_MARKET_ADDRESS=", initialMarket);
    }
}
