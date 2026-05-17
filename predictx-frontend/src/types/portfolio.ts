export type Position = {
  marketId: string;
  marketTitle: string;
  yesShares: number;
  noShares: number;
  avgEntry: number;
  currentProbYes: number;
  unrealizedPnlUsd: number;
};

export type LpPosition = {
  marketId: string;
  marketTitle: string;
  ownershipPct: number;
  depositedUsd: number;
  feesEarnedUsd: number;
};

export type Portfolio = {
  account: string;
  governanceTokenBalance: number;
  votingPower: number;
  realizedPnlUsd: number;
  positions: Position[];
  lpPositions: LpPosition[];
};
