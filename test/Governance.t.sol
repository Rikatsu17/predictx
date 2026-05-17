// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {
    PredictAIToken
} from "src/token/PredictAIToken.sol";

import {
    IVotes
} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {
    PredictAITimelock
} from "src/governance/Timelock.sol";

import {
    PredictAIGovernor
} from "src/governance/PredictAIGovernor.sol";

contract GovernanceTest is Test {

    PredictAIToken token;

    PredictAITimelock timelock;

    PredictAIGovernor governor;

    address alice = address(1);

    function setUp() public {

        token =
            new PredictAIToken();

        address[] memory proposers =
            new address[](1);

        proposers[0] = address(0);

        address[] memory executors =
            new address[](1);

        executors[0] = address(0);

        timelock =
            new PredictAITimelock(
                proposers,
                executors
            );

        governor =
            new PredictAIGovernor(
                IVotes(address(token)),
                timelock
            );

        timelock.grantRole(
            timelock.PROPOSER_ROLE(),
            address(governor)
        );

        timelock.grantRole(
            timelock.EXECUTOR_ROLE(),
            address(0)
        );

        token.transfer(
            alice,
            1000 ether
        );

        vm.prank(alice);

        token.delegate(alice);
    }

    function testVotingPower()
        public
    {
        uint256 votes =
            token.getVotes(alice);

        assertEq(
            votes,
            1000 ether
        );
    }
}