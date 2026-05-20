// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PredictAIToken} from "src/token/PredictAIToken.sol";

import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {PredictAITimelock} from "src/governance/Timelock.sol";

import {PredictAIGovernor} from "src/governance/PredictAIGovernor.sol";
import {MarketFactory} from "src/market/MarketFactory.sol";

import {OracleAdapter} from "src/oracle/OracleAdapter.sol";

contract GovernanceTest is Test {
    PredictAIToken token;

    PredictAITimelock timelock;

    PredictAIGovernor governor;

    MarketFactory factory;

    OracleAdapter oracle;
    address alice = address(1);

    function setUp() public {
        token = new PredictAIToken();
        oracle = new OracleAdapter(true);
        factory = new MarketFactory(address(token), address(oracle));

        address[] memory proposers = new address[](1);

        proposers[0] = address(0);

        address[] memory executors = new address[](1);

        executors[0] = address(0);

        timelock = new PredictAITimelock(proposers, executors);

        factory.transferOwnership(address(timelock));

        governor = new PredictAIGovernor(IVotes(address(token)), timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        token.transfer(alice, 100_000 ether);

        vm.prank(alice);

        token.delegate(alice);

        vm.roll(block.number + 1);
    }

    function testVotingPower() public {
        uint256 votes = token.getVotes(alice);

        assertEq(votes, 100_000 ether);
    }

    function testGovernorSettingsAndInterfaces() public view {
        assertEq(governor.name(), "PredictAI Governor");
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 50400);
        assertEq(governor.proposalThreshold(), 1 ether);
        assertEq(governor.quorum(block.number - 1), token.totalSupply() * 4 / 100);
        assertTrue(governor.supportsInterface(0x01ffc9a7));
    }

    function testProposalNeedsQueuingDefaultsFalseForUnknownProposal() public view {
        assertTrue(governor.proposalNeedsQueuing(uint256(keccak256("unknown"))));
    }

    function testGovernanceProposalLifecycle() public {
        OracleAdapter newOracle = new OracleAdapter(false);

        address[] memory targets = new address[](1);

        targets[0] = address(factory);

        uint256[] memory values = new uint256[](1);

        values[0] = 0;

        bytes[] memory calldatas = new bytes[](1);

        calldatas[0] = abi.encodeWithSignature("updateOracle(address)", address(newOracle));

        string memory description = "Update oracle";

        vm.prank(alice);

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(alice);

        governor.castVote(proposalId, 1);

        vm.roll(block.number + governor.votingPeriod() + 1);

        bytes32 descriptionHash = keccak256(bytes(description));

        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + 2 days + 1);

        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(factory.oracle(), address(newOracle));
    }
}
