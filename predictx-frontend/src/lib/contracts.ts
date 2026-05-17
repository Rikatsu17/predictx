import type { Address } from 'viem';

import { addressesByChainId, type ContractAddresses } from '@/contracts/addresses';

export const zeroAddress =
  '0x0000000000000000000000000000000000000000' as Address;

export function getContractsForChain(chainId?: number): ContractAddresses | null {
  if (!chainId) {
    return null;
  }

  return addressesByChainId[chainId] ?? null;
}

export function isConfiguredAddress(address?: Address | null): address is Address {
  return !!address && address !== zeroAddress;
}
