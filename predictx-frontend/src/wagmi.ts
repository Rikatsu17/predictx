import '@rainbow-me/rainbowkit/styles.css';

import {
  getDefaultConfig
} from '@rainbow-me/rainbowkit';

import {
  arbitrumSepolia,
  baseSepolia,
  optimismSepolia
} from 'wagmi/chains';

export const config =
  getDefaultConfig({
    appName: 'PredictX',

    projectId:
      process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID ??
      '9c17431a44ed5d1f1e1ff1bbcf5e6079',

    chains: [
      arbitrumSepolia,
      baseSepolia,
      optimismSepolia
    ],

    ssr: true
  });
