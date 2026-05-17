'use client';

import { useGovernanceData } from '@/hooks/use-protocol';
import { LiveGovernance } from '@/components/live-governance';

export default function GovernancePage() {
  const { proposals } = useGovernanceData();

  return (
    <main className="page-shell">
      <div className="mx-auto max-w-7xl px-4 pb-16 pt-10 text-slate-100 sm:px-6 lg:px-8">
        <section className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-3xl">
            <p className="section-kicker">DAO governance</p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-white sm:text-5xl">Protocol direction with visible voting pressure.</h1>
            <p className="mt-4 max-w-2xl text-base leading-7 text-slate-300">
              Review proposals, assess quorum momentum, and cast governance actions from a surface that feels as direct as the trading UI.
            </p>
          </div>
          <div className="rounded-[28px] border border-white/8 bg-white/4 px-5 py-4 text-sm text-slate-300">
            {proposals.length} proposals
          </div>
        </section>
        <LiveGovernance />
      </div>
    </main>
  );
}
