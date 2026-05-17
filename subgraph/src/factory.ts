import { Address, BigInt } from "@graphprotocol/graph-ts";
import { MarketCreated } from "../generated/MarketFactory/MarketFactory";
import { PredictionMarket as PredictionMarketTemplate } from "../generated/templates";
import { Market } from "../generated/schema";

export function handleMarketCreated(event: MarketCreated): void {
  let market = new Market(event.params.market.toHex());
  market.creator = event.params.creator;
  market.question = event.params.question;
  market.oracle = event.params.oracle;
  market.endTime = event.params.endTime;
  market.deterministic = event.params.deterministic;
  market.createdAtBlock = event.block.number;
  market.createdAtTimestamp = event.block.timestamp;
  market.totalVolume = BigInt.zero();
  market.yesVolume = BigInt.zero();
  market.noVolume = BigInt.zero();
  market.liquidityAdded = BigInt.zero();
  market.liquidityRemoved = BigInt.zero();
  market.resolved = false;
  market.finalized = false;
  market.save();

  PredictionMarketTemplate.create(Address.fromBytes(event.params.market));
}
