import type { Address } from 'viem';

export type ContractAddresses = {
  predictionMarket: Address;
  marketFactory: Address;
  predictAiToken: Address;
  predictAiGovernor: Address;
  timelockController: Address;
  oracleAdapter: Address;
  sharesErc1155: Address;
};

const zeroAddress =
  '0x0000000000000000000000000000000000000000' as Address;

export const addressesByChainId:
  Record<number, ContractAddresses> = {
    421614: {
      predictionMarket: (process.env.NEXT_PUBLIC_ARB_PREDICTION_MARKET_ADDRESS as Address) ?? zeroAddress,
      marketFactory: (process.env.NEXT_PUBLIC_ARB_MARKET_FACTORY_ADDRESS as Address) ?? zeroAddress,
      predictAiToken: (process.env.NEXT_PUBLIC_ARB_PREDICTAI_TOKEN_ADDRESS as Address) ?? zeroAddress,
      predictAiGovernor: (process.env.NEXT_PUBLIC_ARB_PREDICTAI_GOVERNOR_ADDRESS as Address) ?? zeroAddress,
      timelockController: (process.env.NEXT_PUBLIC_ARB_TIMELOCK_ADDRESS as Address) ?? zeroAddress,
      oracleAdapter: (process.env.NEXT_PUBLIC_ARB_ORACLE_ADAPTER_ADDRESS as Address) ?? zeroAddress,
      sharesErc1155: (process.env.NEXT_PUBLIC_ARB_SHARES_ERC1155_ADDRESS as Address) ?? zeroAddress,
    },
    84532: {
      predictionMarket: (process.env.NEXT_PUBLIC_BASE_PREDICTION_MARKET_ADDRESS as Address) ?? zeroAddress,
      marketFactory: (process.env.NEXT_PUBLIC_BASE_MARKET_FACTORY_ADDRESS as Address) ?? zeroAddress,
      predictAiToken: (process.env.NEXT_PUBLIC_BASE_PREDICTAI_TOKEN_ADDRESS as Address) ?? zeroAddress,
      predictAiGovernor: (process.env.NEXT_PUBLIC_BASE_PREDICTAI_GOVERNOR_ADDRESS as Address) ?? zeroAddress,
      timelockController: (process.env.NEXT_PUBLIC_BASE_TIMELOCK_ADDRESS as Address) ?? zeroAddress,
      oracleAdapter: (process.env.NEXT_PUBLIC_BASE_ORACLE_ADAPTER_ADDRESS as Address) ?? zeroAddress,
      sharesErc1155: (process.env.NEXT_PUBLIC_BASE_SHARES_ERC1155_ADDRESS as Address) ?? zeroAddress,
    },
    11155420: {
      predictionMarket: (process.env.NEXT_PUBLIC_OP_PREDICTION_MARKET_ADDRESS as Address) ?? zeroAddress,
      marketFactory: (process.env.NEXT_PUBLIC_OP_MARKET_FACTORY_ADDRESS as Address) ?? zeroAddress,
      predictAiToken: (process.env.NEXT_PUBLIC_OP_PREDICTAI_TOKEN_ADDRESS as Address) ?? zeroAddress,
      predictAiGovernor: (process.env.NEXT_PUBLIC_OP_PREDICTAI_GOVERNOR_ADDRESS as Address) ?? zeroAddress,
      timelockController: (process.env.NEXT_PUBLIC_OP_TIMELOCK_ADDRESS as Address) ?? zeroAddress,
      oracleAdapter: (process.env.NEXT_PUBLIC_OP_ORACLE_ADAPTER_ADDRESS as Address) ?? zeroAddress,
      sharesErc1155: (process.env.NEXT_PUBLIC_OP_SHARES_ERC1155_ADDRESS as Address) ?? zeroAddress,
    },
  };
