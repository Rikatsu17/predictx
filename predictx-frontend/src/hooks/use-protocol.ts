'use client';

import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { parseEventLogs, type Address } from 'viem';
import { useAccount, useChainId, usePublicClient } from 'wagmi';

import {
  erc1155Abi,
  governorAbi,
  marketFactoryAbi,
  oracleAbi,
  predictAiTokenAbi,
  predictionMarketAbi,
} from '@/contracts/abis';
import { getContractsForChain, isConfiguredAddress } from '@/lib/contracts';
import type { Market } from '@/types/market';

export function useProtocolContracts() {
  const chainId = useChainId();
  const contracts = getContractsForChain(chainId);

  return {
    chainId,
    contracts,
    isConfigured: Boolean(
      contracts &&
        (isConfiguredAddress(contracts.marketFactory) || isConfiguredAddress(contracts.predictionMarket))
    ),
  };
}

export function useLiveMarkets() {
  const publicClient = usePublicClient();
  const { contracts } = useProtocolContracts();

  const query = useQuery({
    queryKey: ['live-markets', contracts?.marketFactory, contracts?.predictionMarket],
    enabled: Boolean(publicClient && contracts),
    refetchInterval: 10_000,
    queryFn: async () => {
      if (!publicClient || !contracts) {
        return [] as Market[];
      }

      let marketAddresses: readonly Address[] = [];

      if (isConfiguredAddress(contracts.marketFactory)) {
        marketAddresses = await publicClient.readContract({
          abi: marketFactoryAbi,
          address: contracts.marketFactory,
          functionName: 'getMarkets',
        });
      } else if (isConfiguredAddress(contracts.predictionMarket)) {
        marketAddresses = [contracts.predictionMarket];
      }

      const liveMarkets = await Promise.all(
        marketAddresses.map(async (address) => {
          const [question, endTime, resolved, yesReserve, noReserve, totalYesShares, totalNoShares, probability] =
            await Promise.all([
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'question' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'endTime' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'resolved' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'yesReserve' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'noReserve' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'totalYesShares' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'totalNoShares' }),
              publicClient.readContract({ abi: predictionMarketAbi, address, functionName: 'getYesProbability' }),
            ]);

          return {
            id: address,
            title: question,
            category: 'AI',
            probabilityYes: Number(probability),
            volumeUsd: Number(totalYesShares) + Number(totalNoShares),
            liquidityYesUsd: Number(yesReserve),
            liquidityNoUsd: Number(noReserve),
            resolveAt: new Date(Number(endTime) * 1000).toISOString(),
            createdAt: new Date(0).toISOString(),
            status: resolved ? 'Resolved' : 'Open',
          } satisfies Market;
        })
      );

      return liveMarkets;
    },
  });

  return {
    markets: query.data ?? [],
    isLoading: query.isLoading,
    isConfigured: Boolean(contracts && (isConfiguredAddress(contracts.marketFactory) || isConfiguredAddress(contracts.predictionMarket))),
  };
}

export function useMarketDetails(marketAddress: Address) {
  const publicClient = usePublicClient();
  const { contracts } = useProtocolContracts();
  const { address: account } = useAccount();

  return useQuery({
    queryKey: ['market-details', marketAddress, account, contracts?.oracleAdapter, contracts?.sharesErc1155],
    enabled: Boolean(publicClient && isConfiguredAddress(marketAddress)),
    refetchInterval: 10_000,
    queryFn: async () => {
      if (!publicClient) {
        return null;
      }

      const [question, endTime, resolved, yesReserve, noReserve, probability, totalYesShares, totalNoShares] =
        await Promise.all([
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'question' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'endTime' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'resolved' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'yesReserve' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'noReserve' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'getYesProbability' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'totalYesShares' }),
          publicClient.readContract({ abi: predictionMarketAbi, address: marketAddress, functionName: 'totalNoShares' }),
        ]);

      const oracleStale =
        contracts && isConfiguredAddress(contracts.oracleAdapter)
          ? await publicClient.readContract({
              abi: oracleAbi,
              address: contracts.oracleAdapter,
              functionName: 'isStale',
            })
          : false;

      const yesBalance =
        contracts && account && isConfiguredAddress(contracts.sharesErc1155)
          ? await publicClient.readContract({
              abi: erc1155Abi,
              address: contracts.sharesErc1155,
              functionName: 'balanceOf',
              args: [account, BigInt(1)],
            })
          : BigInt(0);

      const noBalance =
        contracts && account && isConfiguredAddress(contracts.sharesErc1155)
          ? await publicClient.readContract({
              abi: erc1155Abi,
              address: contracts.sharesErc1155,
              functionName: 'balanceOf',
              args: [account, BigInt(2)],
            })
          : BigInt(0);

      return {
        question,
        endTime,
        resolved,
        yesReserve,
        noReserve,
        probability,
        totalYesShares,
        totalNoShares,
        oracleStale,
        yesBalance,
        noBalance,
      };
    },
  });
}

export function useGovernanceData() {
  const publicClient = usePublicClient();
  const { contracts } = useProtocolContracts();
  const { address } = useAccount();

  const query = useQuery({
    queryKey: ['governance-data', contracts?.predictAiGovernor, contracts?.predictAiToken, address],
    enabled: Boolean(publicClient && contracts && isConfiguredAddress(contracts.predictAiGovernor) && isConfiguredAddress(contracts.predictAiToken)),
    refetchInterval: 10_000,
    queryFn: async () => {
      if (!publicClient || !contracts || !isConfiguredAddress(contracts.predictAiGovernor) || !isConfiguredAddress(contracts.predictAiToken)) {
        return {
          proposals: [],
          governanceTokenBalance: BigInt(0),
          votingPower: BigInt(0),
        };
      }

      const [governanceTokenBalance, votingPower, logs] = await Promise.all([
        address
          ? publicClient.readContract({
              abi: predictAiTokenAbi,
              address: contracts.predictAiToken,
              functionName: 'balanceOf',
              args: [address],
            })
          : Promise.resolve(BigInt(0)),
        address
          ? publicClient.readContract({
              abi: predictAiTokenAbi,
              address: contracts.predictAiToken,
              functionName: 'getVotes',
              args: [address],
            })
          : Promise.resolve(BigInt(0)),
        publicClient.getLogs({
          address: contracts.predictAiGovernor,
          event: governorAbi[2],
          fromBlock: BigInt(0),
          toBlock: 'latest',
        }),
      ]);

      const parsed = parseEventLogs({
        abi: governorAbi,
        logs,
        eventName: 'ProposalCreated',
      });

      const states = await Promise.all(
        parsed.map((entry) =>
          publicClient.readContract({
            abi: governorAbi,
            address: contracts.predictAiGovernor!,
            functionName: 'state',
            args: [entry.args.proposalId],
          })
        )
      );

      const stateMap = ['Pending', 'Active', 'Canceled', 'Defeated', 'Succeeded', 'Queued', 'Expired', 'Executed'];

      return {
        governanceTokenBalance,
        votingPower,
        proposals: parsed.map((entry, index) => ({
          id: entry.args.proposalId.toString(),
          title: entry.args.description,
          proposer: entry.args.proposer,
          state: stateMap[Number(states[index])] ?? 'Pending',
        })),
      };
    },
  });

  return {
    proposals: query.data?.proposals ?? [],
    governanceTokenBalance: Number(query.data?.governanceTokenBalance ?? BigInt(0)),
    votingPower: Number(query.data?.votingPower ?? BigInt(0)),
    isLoading: query.isLoading,
  };
}

export function useContractWarnings() {
  const { contracts, isConfigured } = useProtocolContracts();

  return useMemo(
    () => ({
      missingDeployment: !isConfigured,
      hasFactory: Boolean(contracts && isConfiguredAddress(contracts.marketFactory)),
    }),
    [contracts, isConfigured]
  );
}

export function useLiveProtocolStats() {
  const { markets, isLoading, isConfigured } = useLiveMarkets();

  const stats = useMemo(() => {
    const tvl = markets.reduce((sum, market) => sum + market.liquidityYesUsd + market.liquidityNoUsd, 0);
    const volume = markets.reduce((sum, market) => sum + market.volumeUsd, 0);
    const activeMarkets = markets.filter((market) => market.status === 'Open').length;

    return {
      tvl,
      volume,
      activeMarkets,
      marketsCount: markets.length,
    };
  }, [markets]);

  return {
    ...stats,
    isLoading,
    isConfigured,
  };
}

export function usePortfolioData() {
  const { address } = useAccount();
  const { contracts } = useProtocolContracts();
  const { markets, isLoading: marketsLoading } = useLiveMarkets();
  const publicClient = usePublicClient();

  const query = useQuery({
    queryKey: ['portfolio-data', address, contracts?.sharesErc1155, contracts?.predictAiToken, markets.map((market) => market.id).join('-')],
    enabled: Boolean(publicClient && address && contracts),
    queryFn: async () => {
      if (!publicClient || !address || !contracts) {
        return null;
      }

      const governanceTokenBalance =
        isConfiguredAddress(contracts.predictAiToken)
          ? await publicClient.readContract({
              abi: predictAiTokenAbi,
              address: contracts.predictAiToken,
              functionName: 'balanceOf',
              args: [address],
            })
          : BigInt(0);

      const votingPower =
        isConfiguredAddress(contracts.predictAiToken)
          ? await publicClient.readContract({
              abi: predictAiTokenAbi,
              address: contracts.predictAiToken,
              functionName: 'getVotes',
              args: [address],
            })
          : BigInt(0);

      const yesBalance =
        isConfiguredAddress(contracts.sharesErc1155)
          ? await publicClient.readContract({
              abi: erc1155Abi,
              address: contracts.sharesErc1155,
              functionName: 'balanceOf',
              args: [address, BigInt(1)],
            })
          : BigInt(0);

      const noBalance =
        isConfiguredAddress(contracts.sharesErc1155)
          ? await publicClient.readContract({
              abi: erc1155Abi,
              address: contracts.sharesErc1155,
              functionName: 'balanceOf',
              args: [address, BigInt(2)],
            })
          : BigInt(0);

      return {
        governanceTokenBalance,
        votingPower,
        yesBalance,
        noBalance,
        marketsCount: markets.length,
      };
    },
  });

  return {
    data: query.data,
    isLoading: query.isLoading || marketsLoading,
  };
}
