import { CreateMarketPanel } from '@/components/create-market-panel';
import { LiveMarketExplorer } from '@/components/live-market-explorer';

export default function MarketsPage() {
  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        <section className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="section-kicker">Market explorer</p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-white sm:text-5xl">Discover the strongest AI and tech narratives.</h1>
            <p className="mt-4 max-w-2xl text-base leading-7 text-slate-300">
              Browse active markets, compare liquidity, and prioritize the setups where the crowd is mispricing the future.
            </p>
          </div>
          <div className="glass-panel grid grid-cols-2 gap-3 rounded-[28px] p-4 sm:grid-cols-4">
            <FilterChip label="Newest" active />
            <FilterChip label="Volume" />
            <FilterChip label="Probability" />
            <FilterChip label="Ending soon" />
          </div>
        </section>
        <div className="mt-10 grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
          <CreateMarketPanel />
          <LiveMarketExplorer />
        </div>
      </div>
    </main>
  );
}

function FilterChip({ label, active = false }: { label: string; active?: boolean }) {
  return (
    <button
      className={`rounded-2xl px-4 py-3 text-sm font-medium transition ${
        active
          ? 'bg-white text-slate-950'
          : 'border border-white/8 bg-white/4 text-slate-300 hover:text-white'
      }`}
    >
      {label}
    </button>
  );
}
