import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
  LiquidityAdded,
  LiquidityRemoved,
  MarketFinalized,
  MarketResolved,
  SharesPurchased,
  Swap
} from "../generated/templates/PredictionMarket/PredictionMarket";
import { LiquidityPosition, Market, Resolution, Trade } from "../generated/schema";

function loadMarket(id: string): Market {
  let market = Market.load(id);
  if (market == null) {
    market = new Market(id);
    market.creator = new Bytes(20);
    market.question = "";
    market.oracle = new Bytes(20);
    market.endTime = BigInt.zero();
    market.createdAtBlock = BigInt.zero();
    market.createdAtTimestamp = BigInt.zero();
    market.totalVolume = BigInt.zero();
    market.yesVolume = BigInt.zero();
    market.noVolume = BigInt.zero();
    market.liquidityAdded = BigInt.zero();
    market.liquidityRemoved = BigInt.zero();
    market.resolved = false;
    market.finalized = false;
    market.deterministic = false;
  }
  return market as Market;
}

export function handleSharesPurchased(event: SharesPurchased): void {
  let market = loadMarket(event.address.toHex());
  market.totalVolume = market.totalVolume.plus(event.params.collateralIn);
  market.save();

  let trade = new Trade(event.transaction.hash.toHex() + "-buy-" + event.logIndex.toString());
  trade.market = market.id;
  trade.trader = event.params.buyer;
  trade.kind = "BUY";
  trade.tokenIn = event.params.tokenId;
  trade.amountIn = event.params.collateralIn;
  trade.amountOut = event.params.sharesOut;
  trade.txHash = event.transaction.hash;
  trade.timestamp = event.block.timestamp;
  trade.save();
}

export function handleLiquidityAdded(event: LiquidityAdded): void {
  let market = loadMarket(event.address.toHex());
  market.liquidityAdded = market.liquidityAdded.plus(event.params.lpSharesMinted);
  market.save();

  let id = event.address.toHex() + "-" + event.params.provider.toHex();
  let position = LiquidityPosition.load(id);
  if (position == null) {
    position = new LiquidityPosition(id);
    position.market = market.id;
    position.provider = event.params.provider;
    position.totalYesDeposited = BigInt.zero();
    position.totalNoDeposited = BigInt.zero();
    position.totalLpMinted = BigInt.zero();
    position.totalLpBurned = BigInt.zero();
  }
  position.totalYesDeposited = position.totalYesDeposited.plus(event.params.yesAmount);
  position.totalNoDeposited = position.totalNoDeposited.plus(event.params.noAmount);
  position.totalLpMinted = position.totalLpMinted.plus(event.params.lpSharesMinted);
  position.save();
}

export function handleLiquidityRemoved(event: LiquidityRemoved): void {
  let market = loadMarket(event.address.toHex());
  market.liquidityRemoved = market.liquidityRemoved.plus(event.params.lpSharesBurned);
  market.save();

  let id = event.address.toHex() + "-" + event.params.provider.toHex();
  let position = LiquidityPosition.load(id);
  if (position == null) {
    return;
  }
  position.totalLpBurned = position.totalLpBurned.plus(event.params.lpSharesBurned);
  position.save();
}

export function handleSwap(event: Swap): void {
  let trade = new Trade(event.transaction.hash.toHex() + "-swap-" + event.logIndex.toString());
  trade.market = event.address.toHex();
  trade.trader = event.params.trader;
  trade.kind = "SWAP";
  trade.tokenIn = event.params.tokenIn;
  trade.tokenOut = event.params.tokenOut;
  trade.amountIn = event.params.amountIn;
  trade.amountOut = event.params.amountOut;
  trade.txHash = event.transaction.hash;
  trade.timestamp = event.block.timestamp;
  trade.save();
}

export function handleMarketResolved(event: MarketResolved): void {
  let market = loadMarket(event.address.toHex());
  market.resolved = true;
  market.outcome = event.params.outcome;
  market.save();

  let resolution = new Resolution(event.transaction.hash.toHex() + "-resolved");
  resolution.market = market.id;
  resolution.resolvedAt = event.params.resolvedAt;
  resolution.outcome = event.params.outcome;
  resolution.finalized = false;
  resolution.save();
}

export function handleMarketFinalized(event: MarketFinalized): void {
  let market = loadMarket(event.address.toHex());
  market.finalized = true;
  market.outcome = event.params.outcome;
  market.save();

  let resolution = new Resolution(event.transaction.hash.toHex() + "-finalized");
  resolution.market = market.id;
  resolution.resolvedAt = event.params.finalizedAt;
  resolution.finalizedAt = event.params.finalizedAt;
  resolution.outcome = event.params.outcome;
  resolution.finalized = true;
  resolution.save();
}
