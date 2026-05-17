import '@rainbow-me/rainbowkit/styles.css';

import {
  getDefaultConfig
} from '@rainbow-me/rainbowkit';

import {
  arbitrumSepolia
} from 'wagmi/chains';

export const config =
  getDefaultConfig({
    appName: 'PredictX',

    projectId:
      '9c17431a44ed5d1f1e1ff1bbcf5e6079',

    chains: [
      arbitrumSepolia
    ],

    ssr: true
  });