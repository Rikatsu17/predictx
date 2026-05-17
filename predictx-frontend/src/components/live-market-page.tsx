'use client';

import type { Address } from 'viem';

import { LiquidityPanel } from '@/components/liquidity-panel';
import { ProbabilityBar } from '@/components/probability-bar';
import { TradePanel } from '@/components/trade-panel';
import { useMarketDetails } from '@/hooks/use-protocol';
import { formatUsd } from '@/lib/format';

export function LiveMarketPage({ marketAddress }: { marketAddress: Address }) {
  const details = useMarketDetails(marketAddress);
  const question = details.data?.question ?? marketAddress;
  const endTime = Number(details.data?.endTime ?? BigInt(0));
  const resolved = Boolean(details.data?.resolved);
  const yesReserve = details.data?.yesReserve ?? BigInt(0);
  const noReserve = details.data?.noReserve ?? BigInt(0);
  const probability = Number(details.data?.probability ?? BigInt(0));
  const totalYesShares = Number(details.data?.totalYesShares ?? BigInt(0));
  const totalNoShares = Number(details.data?.totalNoShares ?? BigInt(0));
  const oracleStale = Boolean(details.data?.oracleStale ?? false);
  const yesBalance = Number(details.data?.yesBalance ?? BigInt(0));
  const noBalance = Number(details.data?.noBalance ?? BigInt(0));

  return (
    <>
      {details.isLoading ? <div className="mb-6 text-sm text-slate-400">Loading onchain market state...</div> : null}
      <section className="glass-panel rounded-[32px] p-6">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="section-kicker">Live market</p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-white sm:text-5xl">{question}</h1>
            <p className="mt-4 max-w-2xl text-base leading-7 text-slate-300">
              This view reads reserves, probability, resolution state, and wallet balances directly from the deployed market.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            <TopMetric label="Probability" value={`${probability.toFixed(1)}%`} />
            <TopMetric label="Volume" value={formatUsd(totalYesShares + totalNoShares)} />
            <TopMetric label="YES reserve" value={yesReserve.toString()} />
            <TopMetric label="NO reserve" value={noReserve.toString()} />
          </div>
        </div>
        <div className="mt-6 rounded-[28px] border border-white/8 bg-black/15 p-5">
          <ProbabilityBar yes={probability} />
        </div>
      </section>

      <section className="mt-8 grid gap-6 lg:grid-cols-[1.1fr_0.9fr]">
        <div className="space-y-6">
          <div className="grid gap-6 xl:grid-cols-[0.9fr_1.1fr]">
            <div className="glass-panel rounded-[28px] p-5">
              <p className="section-kicker">Market stats</p>
              <div className="mt-5 grid gap-3 sm:grid-cols-2">
                <InfoCard label="Resolution" value={endTime ? new Date(endTime * 1000).toLocaleDateString('en-US') : '-'} />
                <InfoCard label="Status" value={resolved ? 'Resolved' : 'Open'} />
                <InfoCard label="Wallet YES" value={yesBalance.toString()} />
                <InfoCard label="Wallet NO" value={noBalance.toString()} />
              </div>
            </div>
            <TradePanel marketAddress={marketAddress} yesReserve={yesReserve} noReserve={noReserve} />
          </div>
        </div>
        <div className="space-y-6">
          <LiquidityPanel marketAddress={marketAddress} />
          <section className="glass-panel rounded-[28px] p-5">
            <p className="section-kicker">Oracle status</p>
            <h2 className="mt-2 text-xl font-semibold text-white">Resolution readiness</h2>
            <div className="mt-5 grid gap-3">
              <InfoCard label="Oracle stale" value={oracleStale ? 'Yes' : 'No'} />
              <InfoCard label="Contract address" value={marketAddress} />
            </div>
          </section>
        </div>
      </section>
    </>
  );
}

function TopMetric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-[22px] border border-white/8 bg-black/15 p-4">
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className="metric-value mt-3 text-lg font-semibold text-white">{value}</p>
    </div>
  );
}

function InfoCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-[22px] border border-white/8 bg-white/4 p-4">
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className="metric-value mt-2 break-all text-sm font-medium text-white">{value}</p>
    </div>
  );
}
