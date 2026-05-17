'use client';

import { useAccount, useChainId } from 'wagmi';

import { supportedChainIds } from '@/lib/chains';

export function NetworkGuard({
  children
}: {
  children: React.ReactNode;
}) {
  const { isConnected } = useAccount();
  const chainId = useChainId();
  const supported = supportedChainIds.has(chainId);

  if (isConnected && !supported) {
    return (
      <div className="mx-auto mt-6 max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="rounded-2xl border border-amber-500/30 bg-amber-500/10 p-4 text-sm text-amber-100">
          Unsupported network. Switch to Arbitrum Sepolia, Base Sepolia, or Optimism Sepolia.
        </div>
      </div>
    );
  }

  return children;
}
