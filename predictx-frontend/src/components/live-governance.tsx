'use client';

import type { Address } from 'viem';

import { GovernanceTimeline } from '@/components/governance-timeline';
import { ProposalCard } from '@/components/proposal-card';
import { VotePanel } from '@/components/vote-panel';
import { useGovernanceData, useProtocolContracts } from '@/hooks/use-protocol';

export function LiveGovernance() {
  const { contracts } = useProtocolContracts();
  const { proposals, governanceTokenBalance, votingPower, isLoading } = useGovernanceData();

  const governorAddress = contracts?.predictAiGovernor as Address | undefined;
  const tokenAddress = contracts?.predictAiToken as Address | undefined;

  if (!governorAddress || !tokenAddress) {
    return (
      <div className="rounded-[24px] border border-amber-400/20 bg-amber-400/8 p-4 text-sm text-amber-100">
        Configure governor and token addresses to enable live governance actions.
      </div>
    );
  }

  return (
    <div className="mt-8 grid gap-6 lg:grid-cols-[1.1fr_0.9fr]">
      <div className="space-y-5">
        {isLoading ? <div className="text-sm text-slate-400">Loading live governance data...</div> : null}
        {proposals.length ? (
          proposals.map((proposal) => (
            <ProposalCard
              key={proposal.id}
              proposal={{
                id: proposal.id,
                title: proposal.title,
                proposer: proposal.proposer,
                forVotes: 0,
                againstVotes: 0,
                abstainVotes: 0,
                quorumBps: 4,
                eta: '',
                state: proposal.state as never,
              }}
            />
          ))
        ) : (
          <div className="rounded-[24px] border border-white/8 bg-white/4 p-4 text-sm text-slate-400">
            No `ProposalCreated` events found on the configured governor yet.
          </div>
        )}
      </div>
      <div className="space-y-5">
        <div className="glass-panel rounded-[28px] p-5">
          <p className="section-kicker">Token state</p>
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <Metric label="PAI balance" value={governanceTokenBalance.toString()} />
            <Metric label="Votes" value={votingPower.toString()} />
          </div>
        </div>
        <VotePanel
          governorAddress={governorAddress}
          tokenAddress={tokenAddress}
          initialProposalId={proposals[0]?.id}
          votingPower={votingPower}
        />
        <GovernanceTimeline />
      </div>
    </div>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-[22px] border border-white/8 bg-black/15 p-4">
      <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">{label}</p>
      <p className="metric-value mt-2 text-lg font-semibold text-white">{value}</p>
    </div>
  );
}
