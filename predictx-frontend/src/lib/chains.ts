import {
  arbitrumSepolia,
  baseSepolia,
  optimismSepolia
} from 'wagmi/chains';

export const supportedChains = [
  arbitrumSepolia,
  baseSepolia,
  optimismSepolia
];

export const supportedChainIds =
  new Set<number>(supportedChains.map((chain) => chain.id));
