export const marketFactoryAbi = [
  {
    type: 'function',
    name: 'getMarkets',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'address[]' }],
  },
  {
    type: 'function',
    name: 'createMarket',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'question', type: 'string' },
      { name: 'endTime', type: 'uint256' },
      { name: 'salt', type: 'bytes32' },
    ],
    outputs: [{ name: '', type: 'address' }],
  },
  {
    type: 'function',
    name: 'oracle',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'address' }],
  },
] as const;

export const predictionMarketAbi = [
  {
    type: 'function',
    name: 'question',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'string' }],
  },
  {
    type: 'function',
    name: 'endTime',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'resolved',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    type: 'function',
    name: 'outcome',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    type: 'function',
    name: 'yesReserve',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'noReserve',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'totalYesShares',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'totalNoShares',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'getYesProbability',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'getAmountOut',
    stateMutability: 'pure',
    inputs: [
      { name: 'amountIn', type: 'uint256' },
      { name: 'reserveIn', type: 'uint256' },
      { name: 'reserveOut', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'buyYesShares',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'amount', type: 'uint256' }],
    outputs: [],
  },
  {
    type: 'function',
    name: 'buyNoShares',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'amount', type: 'uint256' }],
    outputs: [],
  },
  {
    type: 'function',
    name: 'provideLiquidity',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'yesAmount', type: 'uint256' },
      { name: 'noAmount', type: 'uint256' },
    ],
    outputs: [],
  },
  {
    type: 'function',
    name: 'swapYesForNo',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'yesIn', type: 'uint256' },
      { name: 'minNoOut', type: 'uint256' },
    ],
    outputs: [{ name: 'noOut', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'swapNoForYes',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'noIn', type: 'uint256' },
      { name: 'minYesOut', type: 'uint256' },
    ],
    outputs: [{ name: 'yesOut', type: 'uint256' }],
  },
] as const;

export const erc1155Abi = [
  {
    type: 'function',
    name: 'balanceOf',
    stateMutability: 'view',
    inputs: [
      { name: 'account', type: 'address' },
      { name: 'id', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
  },
] as const;

export const predictAiTokenAbi = [
  {
    type: 'function',
    name: 'balanceOf',
    stateMutability: 'view',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'delegate',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'delegatee', type: 'address' }],
    outputs: [],
  },
  {
    type: 'function',
    name: 'getVotes',
    stateMutability: 'view',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
] as const;

export const governorAbi = [
  {
    type: 'function',
    name: 'castVote',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'proposalId', type: 'uint256' },
      { name: 'support', type: 'uint8' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    type: 'function',
    name: 'state',
    stateMutability: 'view',
    inputs: [{ name: 'proposalId', type: 'uint256' }],
    outputs: [{ name: '', type: 'uint8' }],
  },
  {
    type: 'event',
    name: 'ProposalCreated',
    inputs: [
      { indexed: true, name: 'proposalId', type: 'uint256' },
      { indexed: true, name: 'proposer', type: 'address' },
      { indexed: false, name: 'targets', type: 'address[]' },
      { indexed: false, name: 'values', type: 'uint256[]' },
      { indexed: false, name: 'signatures', type: 'string[]' },
      { indexed: false, name: 'calldatas', type: 'bytes[]' },
      { indexed: false, name: 'voteStart', type: 'uint256' },
      { indexed: false, name: 'voteEnd', type: 'uint256' },
      { indexed: false, name: 'description', type: 'string' },
    ],
  },
  {
    type: 'event',
    name: 'VoteCast',
    inputs: [
      { indexed: true, name: 'voter', type: 'address' },
      { indexed: true, name: 'proposalId', type: 'uint256' },
      { indexed: false, name: 'support', type: 'uint8' },
      { indexed: false, name: 'weight', type: 'uint256' },
      { indexed: false, name: 'reason', type: 'string' },
    ],
  },
] as const;

export const oracleAbi = [
  {
    type: 'function',
    name: 'getOutcome',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'bool' }],
  },
  {
    type: 'function',
    name: 'isStale',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'bool' }],
  },
] as const;
