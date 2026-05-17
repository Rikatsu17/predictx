'use client';

import { useLiveProtocolStats } from '@/hooks/use-protocol';
import { formatUsd } from '@/lib/format';

export default function AnalyticsPage() {
  const stats = useLiveProtocolStats();

  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        <section className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="section-kicker">Analytics</p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-white sm:text-5xl">Track protocol health like an operator, not a spectator.</h1>
            <p className="mt-4 max-w-2xl text-base leading-7 text-slate-300">
              Volume, TVL, fees, treasury growth, and market activity framed like a real crypto control room.
            </p>
          </div>
        </section>

        <section className="mt-8 grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          <Stat label="TVL" value={formatUsd(stats.tvl)} />
          <Stat label="Volume" value={formatUsd(stats.volume)} />
          <Stat label="Markets loaded" value={stats.marketsCount.toLocaleString()} />
          <Stat label="Active markets" value={stats.activeMarkets.toLocaleString()} />
          <Stat label="Factory" value={stats.isConfigured ? 'Configured' : 'Missing'} />
          <Stat label="Sync" value={stats.isLoading ? 'Loading' : 'Ready'} />
        </section>

        <section className="glass-panel mt-8 rounded-[30px] p-5">
          <div className="flex items-end justify-between gap-4">
            <div>
              <p className="section-kicker">Growth snapshots</p>
              <h2 className="mt-2 text-xl font-semibold text-white">Volume vs TVL</h2>
            </div>
          </div>
          <div className="mt-6 grid gap-3 md:grid-cols-5">
            <div className="rounded-[24px] border border-white/8 bg-black/15 p-4 md:col-span-5">
              <p className="text-sm leading-6 text-slate-300">
                Historical snapshots are not indexed yet. This screen now shows only live protocol-level data derived from deployed
                markets instead of fabricated analytics.
              </p>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="glass-panel rounded-[28px] p-5">
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className="metric-value mt-3 text-3xl font-semibold text-white">{value}</p>
    </div>
  );
}
