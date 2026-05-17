'use client';

import { useState } from 'react';
import { parseUnits, type Address } from 'viem';
import { useWaitForTransactionReceipt, useWriteContract, useReadContract } from 'wagmi';

import { predictionMarketAbi } from '@/contracts/abis';
import { TransactionStatus } from '@/components/transaction-status';

export function TradePanel({
  marketAddress,
  yesReserve = 0n,
  noReserve = 0n,
}: {
  marketAddress: Address;
  yesReserve?: bigint;
  noReserve?: bigint;
}) {
  const [amount, setAmount] = useState('100');
  const [mode, setMode] = useState<'buy-yes' | 'buy-no' | 'swap-yes-no' | 'swap-no-yes'>('buy-yes');
  const { data: hash, error, isPending, writeContract } = useWriteContract();
  const receipt = useWaitForTransactionReceipt({ hash });

  let parsedAmount = 0n;
  try {
    parsedAmount = parseUnits(amount || '0', 0);
  } catch {}

  const preview = useReadContract({
    abi: predictionMarketAbi,
    address: marketAddress,
    functionName: 'getAmountOut',
    args:
      mode === 'swap-yes-no'
        ? [parsedAmount, yesReserve, noReserve]
        : mode === 'swap-no-yes'
          ? [parsedAmount, noReserve, yesReserve]
          : undefined,
    query: {
      enabled: mode === 'swap-yes-no' || mode === 'swap-no-yes',
    },
  });

  function submitTrade() {
    if (parsedAmount <= 0n) {
      return;
    }

    if (mode === 'buy-yes') {
      writeContract({
        abi: predictionMarketAbi,
        address: marketAddress,
        functionName: 'buyYesShares',
        args: [parsedAmount],
      });
      return;
    }

    if (mode === 'buy-no') {
      writeContract({
        abi: predictionMarketAbi,
        address: marketAddress,
        functionName: 'buyNoShares',
        args: [parsedAmount],
      });
      return;
    }

    if (mode === 'swap-yes-no') {
      writeContract({
        abi: predictionMarketAbi,
        address: marketAddress,
        functionName: 'swapYesForNo',
        args: [parsedAmount, 1n],
      });
      return;
    }

    writeContract({
      abi: predictionMarketAbi,
      address: marketAddress,
      functionName: 'swapNoForYes',
      args: [parsedAmount, 1n],
    });
  }

  return (
    <section className="glass-panel rounded-[28px] p-5">
      <div className="flex items-center justify-between gap-3">
        <div>
          <p className="section-kicker">Execution</p>
          <h2 className="mt-2 text-lg font-semibold text-white">Trade Panel</h2>
        </div>
        <span className="rounded-full border border-white/8 bg-white/4 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-slate-300">
          Onchain
        </span>
      </div>
      <div className="mt-5 grid grid-cols-2 gap-2 text-sm">
        <ModeButton label="Buy YES" active={mode === 'buy-yes'} onClick={() => setMode('buy-yes')} />
        <ModeButton label="Buy NO" active={mode === 'buy-no'} onClick={() => setMode('buy-no')} />
        <ModeButton label="Swap Y->N" active={mode === 'swap-yes-no'} onClick={() => setMode('swap-yes-no')} />
        <ModeButton label="Swap N->Y" active={mode === 'swap-no-yes'} onClick={() => setMode('swap-no-yes')} />
      </div>
      <label className="mt-5 block">
        <span className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Amount</span>
        <input
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
          inputMode="numeric"
          className="mt-2 w-full rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-white outline-none"
          placeholder="100"
        />
      </label>
      <div className="mt-5 grid grid-cols-2 gap-3 text-sm">
        <div className="rounded-2xl border border-white/6 bg-black/10 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Preview</p>
          <p className="metric-value mt-2 text-white">
            {preview.data !== undefined ? preview.data.toString() : mode.startsWith('buy') ? parsedAmount.toString() : '-'}
          </p>
        </div>
        <div className="rounded-2xl border border-white/6 bg-black/10 p-3">
          <p className="text-[11px] uppercase tracking-[0.2em] text-slate-500">Contract model</p>
          <p className="mt-2 text-xs leading-5 text-slate-400">Current market contract mints shares directly and uses reserve math without ERC20 settlement.</p>
        </div>
      </div>
      <button
        onClick={submitTrade}
        disabled={parsedAmount <= 0n || isPending}
        className="mt-5 w-full rounded-2xl bg-[linear-gradient(135deg,#66e0ff,#96f5d2)] px-4 py-3 text-sm font-semibold text-slate-950 disabled:cursor-not-allowed disabled:opacity-60"
      >
        Submit transaction
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

function ModeButton({
  active,
  label,
  onClick,
}: {
  active: boolean;
  label: string;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`rounded-2xl px-3 py-3 font-medium transition ${
        active ? 'bg-white text-slate-950' : 'border border-white/8 bg-white/4 text-slate-300'
      }`}
    >
      {label}
    </button>
  );
}
