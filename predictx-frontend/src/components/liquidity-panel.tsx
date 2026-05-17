'use client';

import { useState } from 'react';
import { parseUnits, type Address } from 'viem';
import { useWaitForTransactionReceipt, useWriteContract } from 'wagmi';

import { predictionMarketAbi } from '@/contracts/abis';
import { TransactionStatus } from '@/components/transaction-status';

export function LiquidityPanel({ marketAddress }: { marketAddress: Address }) {
  const [yesAmount, setYesAmount] = useState('1000');
  const [noAmount, setNoAmount] = useState('1000');
  const { data: hash, error, isPending, writeContract } = useWriteContract();
  const receipt = useWaitForTransactionReceipt({ hash });

  let parsedYes = 0n;
  let parsedNo = 0n;

  try {
    parsedYes = parseUnits(yesAmount || '0', 0);
  } catch {}

  try {
    parsedNo = parseUnits(noAmount || '0', 0);
  } catch {}

  return (
    <section className="glass-panel rounded-[28px] p-5">
      <p className="section-kicker">AMM</p>
      <h2 className="mt-2 text-lg font-semibold text-white">Liquidity</h2>
      <div className="mt-5 grid gap-3">
        <input
          value={yesAmount}
          onChange={(event) => setYesAmount(event.target.value)}
          inputMode="numeric"
          className="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
          placeholder="YES amount"
        />
        <input
          value={noAmount}
          onChange={(event) => setNoAmount(event.target.value)}
          inputMode="numeric"
          className="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
          placeholder="NO amount"
        />
      </div>
      <button
        onClick={() =>
          writeContract({
            abi: predictionMarketAbi,
            address: marketAddress,
            functionName: 'provideLiquidity',
            args: [parsedYes, parsedNo],
          })
        }
        disabled={parsedYes <= 0n || parsedNo <= 0n || isPending}
        className="mt-5 w-full rounded-2xl bg-[linear-gradient(135deg,#7a8cff,#9e7dff)] px-4 py-3 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60"
      >
        Add liquidity
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
