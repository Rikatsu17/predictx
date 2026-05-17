'use client';

import Link from 'next/link';

import { CreateMarketPanel } from '@/components/create-market-panel';
import { LiveMarketExplorer } from '@/components/live-market-explorer';
import { useLiveProtocolStats } from '@/hooks/use-protocol';
import { formatUsd } from '@/lib/format';

const featuredSignals = [
  'GPT-6 before 2027',
  'AGI before 2030',
  'NVIDIA above $300',
  'ETH ETF inflows > $10B',
];

export default function Home() {
  const stats = useLiveProtocolStats();

  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        <section className="grid gap-8 lg:grid-cols-[1.15fr_0.85fr] lg:items-end">
          <div className="max-w-3xl">
            <p className="section-kicker">AI and tech prediction exchange</p>
            <h1 className="mt-5 text-5xl font-semibold leading-none tracking-tight text-white sm:text-6xl lg:text-7xl">
              Price the future before the market agrees with you.
            </h1>
            <p className="mt-6 max-w-2xl text-base leading-7 text-slate-300 sm:text-lg">
              PredictX turns frontier AI and technology narratives into liquid onchain markets with live probability discovery,
              governance, and LP participation across L2.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/markets" className="rounded-2xl bg-[linear-gradient(135deg,#66e0ff,#9af5d9)] px-5 py-3 text-sm font-semibold text-slate-950 shadow-[0_16px_40px_rgba(102,224,255,0.22)]">
                Start trading
              </Link>
              <Link href="/analytics" className="rounded-2xl border border-white/10 bg-white/4 px-5 py-3 text-sm font-semibold text-white">
                View analytics
              </Link>
            </div>
            <div className="mt-10 flex flex-wrap gap-2">
              {featuredSignals.map((signal) => (
                <span key={signal} className="rounded-full border border-white/8 bg-white/4 px-4 py-2 text-xs uppercase tracking-[0.18em] text-slate-300">
                  {signal}
                </span>
              ))}
            </div>
          </div>
          <div className="glass-panel overflow-hidden rounded-[32px] p-6">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="section-kicker">Protocol monitor</p>
                <h2 className="mt-2 text-xl font-semibold text-white">Market pulse</h2>
              </div>
              <span className="rounded-full border border-emerald-400/25 bg-emerald-400/10 px-3 py-1 text-[11px] uppercase tracking-[0.2em] text-emerald-200">
                Live
              </span>
            </div>
            <div className="mt-6 grid gap-4 sm:grid-cols-2">
              <Stat label="TVL" value={formatUsd(stats.tvl)} />
              <Stat label="Volume" value={formatUsd(stats.volume)} />
              <Stat label="Loaded markets" value={String(stats.marketsCount)} />
              <Stat label="Active markets" value={String(stats.activeMarkets)} />
            </div>
            <div className="mt-6 rounded-[24px] border border-white/8 bg-black/15 p-4">
              <div className="flex items-end justify-between gap-4">
                <div>
                  <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Factory status</p>
                  <p className="metric-value mt-2 text-3xl font-semibold text-white">{stats.isConfigured ? 'Connected' : 'Unconfigured'}</p>
                </div>
                <span className="rounded-full bg-cyan-300/10 px-3 py-1 text-sm font-medium text-cyan-200">{stats.isLoading ? 'Syncing' : 'Live'}</span>
              </div>
            </div>
          </div>
        </section>

        <section className="mt-14 grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
          <CreateMarketPanel />
          <div>
            <div className="flex items-end justify-between gap-4">
              <div>
                <p className="section-kicker">Featured markets</p>
                <h2 className="mt-3 text-2xl font-semibold text-white">Where the signal is forming right now.</h2>
              </div>
              <Link href="/markets" className="text-sm font-medium text-cyan-200">All markets</Link>
            </div>
            <div className="mt-6">
              <LiveMarketExplorer />
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-[24px] border border-white/8 bg-black/15 p-4">
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className="metric-value mt-3 text-2xl font-semibold text-white">{value}</p>
    </div>
  );
}
