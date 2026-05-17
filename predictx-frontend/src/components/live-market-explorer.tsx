'use client';

import { MarketCard } from '@/components/market-card';
import { useLiveMarkets } from '@/hooks/use-protocol';

export function LiveMarketExplorer() {
  const { markets, isLoading, isConfigured } = useLiveMarkets();

  return (
    <>
      {!isConfigured ? (
        <div className="mb-6 rounded-[24px] border border-amber-400/20 bg-amber-400/8 p-4 text-sm text-amber-100">
          Contract addresses are not configured yet. Add `NEXT_PUBLIC_*` deployment values to load live markets.
        </div>
      ) : null}
      {isLoading ? <div className="text-sm text-slate-400">Loading live markets...</div> : null}
      {!isLoading && !markets.length ? (
        <div className="rounded-[24px] border border-white/8 bg-white/4 p-5 text-sm text-slate-300">
          No live markets found yet. Create the first event from the market explorer.
        </div>
      ) : null}
      {markets.length ? (
        <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          {markets.map((market) => (
            <MarketCard key={market.id} market={market} />
          ))}
        </div>
      ) : null}
    </>
  );
}
