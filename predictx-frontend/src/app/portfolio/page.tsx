'use client';

import { usePortfolioData } from '@/hooks/use-protocol';

export default function PortfolioPage() {
  const portfolio = usePortfolioData();
  const data = portfolio.data;

  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        <section className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="section-kicker">Portfolio</p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-white sm:text-5xl">See every position as a live thesis.</h1>
            <p className="mt-4 max-w-2xl text-base leading-7 text-slate-300">
              YES and NO exposure, LP share, realized returns, and governance weight in one dense but readable workspace.
            </p>
          </div>
          <div className="glass-panel grid grid-cols-1 gap-3 rounded-[28px] p-4 sm:grid-cols-3">
            <Card title="Protocol YES shares" value={data ? data.yesBalance.toString() : '-'} tone="default" />
            <Card title="Governance balance" value={data ? data.governanceTokenBalance.toString() : '-'} />
            <Card title="Voting power" value={data ? data.votingPower.toString() : '-'} />
          </div>
        </section>

        <section className="mt-8 grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
          <div className="glass-panel rounded-[30px] p-5">
            <div className="flex items-end justify-between gap-4">
              <div>
                <p className="section-kicker">Positions</p>
                <h2 className="mt-2 text-xl font-semibold text-white">Directional exposure</h2>
              </div>
            </div>
            <div className="mt-5 space-y-3">
              <div className="rounded-[24px] border border-white/8 bg-white/4 p-4 text-sm leading-6 text-slate-300">
                Outcome shares now come from live chain state only. The current ERC1155 contract uses shared token IDs `1` and `2`
                across all markets, so per-market position attribution is not available from onchain data yet.
              </div>
            </div>
          </div>
          <div className="glass-panel rounded-[30px] p-5">
            <p className="section-kicker">Liquidity positions</p>
            <h2 className="mt-2 text-xl font-semibold text-white">LP accounting</h2>
            <div className="mt-5 space-y-3">
              <MiniStat label="Protocol YES shares" value={data ? data.yesBalance.toString() : '-'} />
              <MiniStat label="Protocol NO shares" value={data ? data.noBalance.toString() : '-'} />
              <MiniStat label="Markets loaded" value={data ? data.marketsCount.toString() : '-'} />
              <div className="rounded-[24px] border border-white/8 bg-black/15 p-4 text-sm leading-6 text-slate-300">
                LP ownership and earned fees are not emitted or stored explicitly by the current market contract, so they cannot be
                reconstructed faithfully without changing Solidity storage/events.
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}

function Card({ title, value, tone = 'default' }: { title: string; value: string; tone?: 'default' | 'good' }) {
  return (
    <div className={`rounded-[24px] p-4 ${tone === 'good' ? 'border border-emerald-400/20 bg-emerald-400/8' : 'border border-white/8 bg-black/15'}`}>
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{title}</p>
      <p className="metric-value mt-3 text-2xl font-semibold text-white">{value}</p>
    </div>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-[20px] border border-white/8 bg-white/4 p-3">
      <p className="text-[11px] uppercase tracking-[0.18em] text-slate-500">{label}</p>
      <p className="metric-value mt-2 text-sm font-medium text-white">{value}</p>
    </div>
  );
}
