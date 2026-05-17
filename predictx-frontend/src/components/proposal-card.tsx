import type { Proposal } from '@/types/governance';

export function ProposalCard({ proposal }: { proposal: Proposal }) {
  return (
    <article className="glass-panel rounded-[28px] p-5">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="section-kicker">{proposal.state}</p>
          <h3 className="mt-3 max-w-xl text-lg font-semibold leading-tight text-white">{proposal.title}</h3>
        </div>
        <span className="rounded-full border border-white/8 bg-white/4 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-slate-300">
          Quorum {proposal.quorumBps}%
        </span>
      </div>
      <div className="mt-5 grid gap-3 md:grid-cols-3 text-sm text-slate-300">
        <div className="rounded-2xl border border-emerald-400/15 bg-emerald-400/6 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-emerald-300/80">For</p>
          <p className="metric-value mt-2 font-medium text-white">{proposal.forVotes.toLocaleString()}</p>
        </div>
        <div className="rounded-2xl border border-rose-400/15 bg-rose-400/6 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-rose-300/80">Against</p>
          <p className="metric-value mt-2 font-medium text-white">{proposal.againstVotes.toLocaleString()}</p>
        </div>
        <div className="rounded-2xl border border-white/8 bg-white/4 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Abstain</p>
          <p className="metric-value mt-2 font-medium text-white">{proposal.abstainVotes.toLocaleString()}</p>
        </div>
      </div>
    </article>
  );
}
