# PredictX — AI & Tech Prediction Market

PredictX is a decentralized on-chain prediction market protocol focused on AI and technology-related events.

Users can trade YES/NO outcome shares for real-world predictions such as:

- Will GPT-6 release before 2027?
- Will NVIDIA stock exceed $300?
- Will AGI arrive before 2030?
- Will Apple release AR glasses?

The protocol is fully decentralized and governed by a DAO using OpenZeppelin Governor + Timelock architecture.

---

# Features

## Core Protocol

- Binary prediction markets
- Constant-product AMM (x * y = k)
- ERC1155 outcome shares
- ERC20 governance token
- ERC20Votes governance system
- DAO-controlled protocol parameters
- Liquidity pools with LP tokens
- Chainlink oracle integration
- ERC4626 treasury vault
- Upgradeable UUPS treasury contract
- CREATE2 deterministic deployment support

---

# Tech Stack

## Smart Contracts

- Solidity
- Foundry
- OpenZeppelin Contracts
- OpenZeppelin Upgradeable Contracts

## Frontend

- Next.js
- TypeScript
- Wagmi
- Viem
- RainbowKit
- TailwindCSS

## Infrastructure

- Arbitrum Sepolia
- The Graph
- GitHub Actions CI/CD
- Slither

---

# Architecture

The protocol consists of several modules:

## Governance

- PredictAIToken (ERC20Votes)
- PredictAIGovernor
- TimelockController

## Market System

- PredictionMarket
- MarketFactory
- PredictionMarketLPToken

## Tokenization

- PredictAIOutcomeShares (ERC1155)

## Treasury

- PredictAITreasuryVault (ERC4626 + UUPS)

## Oracle Layer

- OracleAdapter
- Chainlink price feeds

---

# Smart Contract Features

## Governance

- Proposal creation
- On-chain voting
- Timelock execution
- Quorum enforcement
- Delegated voting power

## Security

- ReentrancyGuard
- AccessControl
- Ownable
- Checks-Effects-Interactions
- Slippage protection
- Oracle staleness checks

## Upgradeability

Treasury vault uses the UUPS proxy pattern with upgrade authorization.

---

# AMM Design

PredictX uses a Constant Product Market Maker:

x * y = k

Features:

- 0.3% swap fee
- YES/NO swaps
- Liquidity provision
- LP token minting
- Probability calculation from reserves

---

# Frontend Features

- Wallet connection (MetaMask + WalletConnect)
- Buy YES shares
- Buy NO shares
- Real-time reserve display
- DAO proposal voting
- Network detection
- Transaction loading/error states
- The Graph indexed data

---

# Testing

The project includes:

- Unit tests
- Fuzz tests
- Invariant tests
- Fork tests

Coverage includes:

- AMM swaps
- Governance voting
- Treasury accounting
- Liquidity management
- Oracle integration

---

# Security

Security tools and practices:

- Slither static analysis
- Access control enforcement
- Reentrancy protection
- CEI pattern
- SafeERC20
- Internal audit report

The protocol also includes reproduced-and-fixed vulnerability case studies:

- Reentrancy attack
- Access control vulnerability

---

# Deployment

## Network

Arbitrum Sepolia Testnet

## Deployment Script

Deployment is fully automated using Foundry scripts.

Example:

```bash
forge script script/DeployProtocol.s.sol:Deploy \
--rpc-url $ARBITRUM_SEPOLIA_RPC_URL \
--broadcast