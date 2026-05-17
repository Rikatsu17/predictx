'use client';

import { useState } from 'react';
import type { Address } from 'viem';
import { useAccount, useWaitForTransactionReceipt, useWriteContract } from 'wagmi';

import { governorAbi, predictAiTokenAbi } from '@/contracts/abis';
import { TransactionStatus } from '@/components/transaction-status';

export function VotePanel({
  governorAddress,
  tokenAddress,
  initialProposalId,
  votingPower,
}: {
  governorAddress: Address;
  tokenAddress: Address;
  initialProposalId?: string;
  votingPower: number;
}) {
  const { address } = useAccount();
  const [proposalId, setProposalId] = useState(initialProposalId ?? '');
  const { data: hash, error, isPending, writeContract } = useWriteContract();
  const receipt = useWaitForTransactionReceipt({ hash });

  let parsedProposalId = 0n;
  try {
    parsedProposalId = BigInt(proposalId || '0');
  } catch {}

  return (
    <section className="glass-panel rounded-[28px] p-5">
      <p className="section-kicker">Governance</p>
      <h2 className="mt-2 text-lg font-semibold text-white">Vote</h2>
      <div className="mt-5 grid gap-3">
        <input
          value={proposalId}
          onChange={(event) => setProposalId(event.target.value)}
          inputMode="numeric"
          className="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
          placeholder="Proposal ID"
        />
      </div>
      <div className="mt-5 grid grid-cols-3 gap-3">
        <button
          onClick={() =>
            writeContract({
              abi: governorAbi,
              address: governorAddress,
              functionName: 'castVote',
              args: [parsedProposalId, 1],
            })
          }
          className="rounded-2xl bg-[linear-gradient(135deg,#7ef1c1,#58dca7)] px-3 py-3 text-sm font-semibold text-slate-950"
        >
          For
        </button>
        <button
          onClick={() =>
            writeContract({
              abi: governorAbi,
              address: governorAddress,
              functionName: 'castVote',
              args: [parsedProposalId, 0],
            })
          }
          className="rounded-2xl bg-[linear-gradient(135deg,#ff8aa2,#ff6f8d)] px-3 py-3 text-sm font-semibold text-slate-950"
        >
          Against
        </button>
        <button
          onClick={() =>
            writeContract({
              abi: governorAbi,
              address: governorAddress,
              functionName: 'castVote',
              args: [parsedProposalId, 2],
            })
          }
          className="rounded-2xl border border-white/10 bg-white/4 px-3 py-3 text-sm font-semibold text-white"
        >
          Abstain
        </button>
      </div>
      <button
        onClick={() =>
          address &&
          writeContract({
            abi: predictAiTokenAbi,
            address: tokenAddress,
            functionName: 'delegate',
            args: [address],
          })
        }
        className="mt-5 w-full rounded-2xl border border-white/10 bg-white/4 px-3 py-3 text-sm font-semibold text-white"
      >
        Delegate to self
      </button>
      <div className="mt-5 rounded-2xl border border-white/6 bg-black/10 p-3">
        <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Voting power</p>
        <p className="metric-value mt-2 text-2xl font-semibold text-white">{votingPower.toString()}</p>
      </div>
      <div className="mt-4">
        <TransactionStatus
          error={error?.message ?? null}
          hash={hash ?? null}
          isPending={isPending || receipt.isLoading}
          isSuccess={receipt.isSuccess}
        />
      </div>
    </section>
  );
}
