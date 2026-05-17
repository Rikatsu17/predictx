# Deployment Setup

## 1. Initialize Foundry dependencies

From the repo root:

```sh
git submodule update --init --recursive
```

If submodules are still missing, install them explicitly:

```sh
forge install foundry-rs/forge-std --no-commit
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit
forge install smartcontractkit/chainlink --no-commit
```

## 2. Build the contracts

```sh
forge build
```

## 3. Set deployment environment variables

```sh
export PRIVATE_KEY=0xYOUR_PRIVATE_KEY
export RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
export ETHERSCAN_API_KEY=YOUR_ARBISCAN_KEY
export INITIAL_MARKET_QUESTION="Will GPT-6 release before 2027?"
export INITIAL_MARKET_END_TIME=1798761600
export INITIAL_MARKET_SALT="PREDICTX_INITIAL_MARKET"
export CREATE_INITIAL_MARKET=true
export INITIAL_ORACLE_OUTCOME=true
```

`INITIAL_MARKET_END_TIME` must be a unix timestamp in seconds.

## 4. Run the deploy script

```sh
forge script script/DeployProtocol.s.sol:DeployProtocolScript \
  --rpc-url "$RPC_URL" \
  --broadcast
```

## 5. Verify contracts

```sh
forge script script/DeployProtocol.s.sol:DeployProtocolScript \
  --rpc-url "$RPC_URL" \
  --broadcast \
  --verify \
  --etherscan-api-key "$ETHERSCAN_API_KEY"
```

## 6. Copy addresses into frontend

Create `predictx-frontend/.env.local` and fill:

```env
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=YOUR_WALLETCONNECT_PROJECT_ID

NEXT_PUBLIC_ARB_MARKET_FACTORY_ADDRESS=0x...
NEXT_PUBLIC_ARB_PREDICTAI_TOKEN_ADDRESS=0x...
NEXT_PUBLIC_ARB_PREDICTAI_GOVERNOR_ADDRESS=0x...
NEXT_PUBLIC_ARB_TIMELOCK_ADDRESS=0x...
NEXT_PUBLIC_ARB_ORACLE_ADAPTER_ADDRESS=0x...
NEXT_PUBLIC_ARB_SHARES_ERC1155_ADDRESS=0x...
NEXT_PUBLIC_ARB_PREDICTION_MARKET_ADDRESS=0x...
```

The deploy script prints these addresses after a successful deployment.

## 7. Start the frontend

```sh
cd predictx-frontend
npm run dev
```
