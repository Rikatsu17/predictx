import Link from 'next/link';

import { formatPct, formatUsd } from '@/lib/format';
import type { Market } from '@/types/market';
import { ProbabilityBar } from '@/components/probability-bar';

export function MarketCard({ market }: { market: Market }) {
  return (
    <Link
      href={`/market/${market.id}`}
      className="glass-panel group block overflow-hidden rounded-[28px] p-5 transition duration-200 hover:-translate-y-1 hover:border-cyan-300/30"
    >
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="section-kicker">{market.category}</p>
          <h3 className="mt-3 max-w-[18rem] text-lg font-semibold leading-tight text-white">{market.title}</h3>
        </div>
        <span className="rounded-full border border-emerald-400/25 bg-emerald-400/10 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-emerald-200">
          {market.status}
        </span>
      </div>
      <div className="mt-8 flex items-end justify-between gap-4">
        <div>
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Probability</p>
          <p className="metric-value mt-2 text-4xl font-semibold text-white">{formatPct(market.probabilityYes)}</p>
        </div>
        <div className="rounded-2xl border border-white/8 bg-white/4 px-4 py-3 text-right">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Volume</p>
          <p className="metric-value mt-1 text-sm font-medium text-slate-100">{formatUsd(market.volumeUsd)}</p>
        </div>
      </div>
      <div className="mt-6">
        <ProbabilityBar yes={market.probabilityYes} />
      </div>
      <div className="mt-6 grid grid-cols-2 gap-3 text-sm text-slate-300">
        <div className="rounded-2xl border border-white/6 bg-black/10 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">YES liquidity</p>
          <p className="metric-value mt-2 font-medium text-white">{formatUsd(market.liquidityYesUsd)}</p>
        </div>
        <div className="rounded-2xl border border-white/6 bg-black/10 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">NO liquidity</p>
          <p className="metric-value mt-2 font-medium text-white">{formatUsd(market.liquidityNoUsd)}</p>
        </div>
      </div>
    </Link>
  );
}
