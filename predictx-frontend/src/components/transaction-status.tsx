'use client';

export function TransactionStatus({
  error,
  hash,
  isPending,
  isSuccess,
}: {
  error?: string | null;
  hash?: string | null;
  isPending?: boolean;
  isSuccess?: boolean;
}) {
  if (!error && !hash && !isPending && !isSuccess) {
    return null;
  }

  return (
    <div className="rounded-2xl border border-white/8 bg-white/4 p-3 text-sm text-slate-300">
      {isPending ? <p>Transaction pending...</p> : null}
      {isSuccess ? <p>Transaction confirmed.</p> : null}
      {hash ? <p className="mt-1 break-all text-xs text-slate-400">Hash {hash}</p> : null}
      {error ? <p className="mt-1 text-rose-300">{error}</p> : null}
    </div>
  );
}
