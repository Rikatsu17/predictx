export type MarketStatus = 'Open' | 'Resolved' | 'Closed';

export type Market = {
  id: string;
  title: string;
  category: 'AI' | 'Tech' | 'Crypto' | 'Macro';
  probabilityYes: number;
  volumeUsd: number;
  liquidityYesUsd: number;
  liquidityNoUsd: number;
  resolveAt: string;
  createdAt: string;
  status: MarketStatus;
};

export type TradeActivity = {
  id: string;
  marketId: string;
  side: 'YES' | 'NO';
  amountUsd: number;
  price: number;
  account: string;
  createdAt: string;
};
