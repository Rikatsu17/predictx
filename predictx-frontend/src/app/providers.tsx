'use client';

import {
  QueryClient,
  QueryClientProvider
} from '@tanstack/react-query';
import { useState } from 'react';

import {
  WagmiProvider
} from 'wagmi';

import {
  RainbowKitProvider
} from '@rainbow-me/rainbowkit';

import { config }
from '../wagmi';
import { ThemeProvider } from '@/providers/theme-provider';

export function Providers({
  children
}: {
  children: React.ReactNode
}) {
  const [queryClient] =
    useState(() => new QueryClient());

  return (
    <WagmiProvider config={config}>

      <QueryClientProvider client={queryClient}>

        <RainbowKitProvider>
          <ThemeProvider>
            {children}
          </ThemeProvider>
        </RainbowKitProvider>

      </QueryClientProvider>

    </WagmiProvider>
  );
}
