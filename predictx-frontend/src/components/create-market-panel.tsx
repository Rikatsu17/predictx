'use client';

import { useState } from 'react';
import { keccak256, toHex } from 'viem';
import { useWaitForTransactionReceipt, useWriteContract } from 'wagmi';

import { marketFactoryAbi } from '@/contracts/abis';
import { TransactionStatus } from '@/components/transaction-status';
import { useProtocolContracts } from '@/hooks/use-protocol';
import { isConfiguredAddress } from '@/lib/contracts';

export function CreateMarketPanel() {
  const { contracts } = useProtocolContracts();
  const [question, setQuestion] = useState('');
  const [endDate, setEndDate] = useState('');
  const { data: hash, error, isPending, writeContract } = useWriteContract();
  const receipt = useWaitForTransactionReceipt({ hash });

  const canCreate =
    contracts &&
    isConfiguredAddress(contracts.marketFactory) &&
    question.trim().length > 0 &&
    endDate.length > 0;

  function createMarket() {
    if (!contracts || !isConfiguredAddress(contracts.marketFactory) || !canCreate) {
      return;
    }

    const endTime = Math.floor(new Date(endDate).getTime() / 1000);
    const salt = keccak256(toHex(`${question}-${endTime}-${Date.now()}`));

    writeContract({
      abi: marketFactoryAbi,
      address: contracts.marketFactory,
      functionName: 'createMarket',
      args: [question.trim(), BigInt(endTime), salt],
    });
  }

  if (!contracts || !isConfiguredAddress(contracts.marketFactory)) {
    return (
      <div className="rounded-[24px] border border-amber-400/20 bg-amber-400/8 p-4 text-sm text-amber-100">
        `MarketFactory` address is not configured yet, so event creation is unavailable.
      </div>
    );
  }

  return (
    <section className="glass-panel rounded-[30px] p-5">
      <p className="section-kicker">Create event</p>
      <h2 className="mt-2 text-xl font-semibold text-white">Launch a new prediction market</h2>
      <div className="mt-5 grid gap-3">
        <input
          value={question}
          onChange={(event) => setQuestion(event.target.value)}
          className="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
          placeholder="Will GPT-6 release before 2027?"
        />
        <input
          value={endDate}
          onChange={(event) => setEndDate(event.target.value)}
          type="datetime-local"
          className="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
        />
      </div>
      <button
        onClick={createMarket}
        disabled={!canCreate || isPending}
        className="mt-5 w-full rounded-2xl bg-[linear-gradient(135deg,#66e0ff,#96f5d2)] px-4 py-3 text-sm font-semibold text-slate-950 disabled:cursor-not-allowed disabled:opacity-60"
      >
        Create event
      </button>
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
