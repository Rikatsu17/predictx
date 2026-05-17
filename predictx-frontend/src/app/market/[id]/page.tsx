import { isAddress, type Address } from 'viem';

import { LiveMarketPage } from '@/components/live-market-page';

export default async function MarketPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        {isAddress(id) ? (
          <LiveMarketPage marketAddress={id as Address} />
        ) : (
          <section className="rounded-[28px] border border-amber-400/20 bg-amber-400/8 p-5 text-sm leading-6 text-amber-100">
            Market pages are now live-only. Open a deployed market by its contract address, or create a new event from `/markets`.
          </section>
        )}
      </div>
    </main>
  );
}
