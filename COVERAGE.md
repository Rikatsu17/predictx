# Coverage Report

Generated on 2026-05-20 with:

```sh
forge coverage --ir-minimum --report summary
```

`--ir-minimum` is required because the default coverage instrumentation hits a Solidity `stack too deep` compiler error in `script/DeployProtocol.s.sol`.

## Result

Source-contract line coverage is **93.49%**: 158 covered lines out of 169 lines in `src/`.

The full Foundry total is lower because Foundry includes deployment scripts in the aggregate table. The project requirement is for contract coverage, so the relevant measurement is the `src/` subtotal.

## Foundry Summary

| File | % Lines | % Statements | % Branches | % Funcs |
| --- | ---: | ---: | ---: | ---: |
| `script/Deploy.s.sol` | 0.00% (0/37) | 0.00% (0/49) | 100.00% (0/0) | 0.00% (0/1) |
| `script/DeployProtocol.s.sol` | 0.00% (0/51) | 0.00% (0/63) | 0.00% (0/1) | 0.00% (0/1) |
| `script/PostDeployCheck.s.sol` | 0.00% (0/11) | 0.00% (0/13) | 0.00% (0/12) | 0.00% (0/1) |
| `src/governance/PredictAIGovernor.sol` | 90.91% (20/22) | 90.48% (19/21) | 100.00% (0/0) | 90.91% (10/11) |
| `src/market/MarketFactory.sol` | 89.47% (17/19) | 87.50% (14/16) | 100.00% (0/0) | 100.00% (5/5) |
| `src/market/PredictionMarket.sol` | 96.30% (52/54) | 96.08% (49/51) | 13.89% (5/36) | 100.00% (9/9) |
| `src/oracle/OracleAdapter.sol` | 100.00% (11/11) | 100.00% (9/9) | 0.00% (0/2) | 100.00% (4/4) |
| `src/token/PredictAIOutcomeShares.sol` | 100.00% (12/12) | 100.00% (7/7) | 100.00% (0/0) | 100.00% (6/6) |
| `src/token/PredictAIToken.sol` | 100.00% (8/8) | 100.00% (5/5) | 100.00% (0/0) | 100.00% (4/4) |
| `src/upgrade/MarketConfigV1.sol` | 95.65% (22/23) | 93.75% (15/16) | 0.00% (0/8) | 100.00% (7/7) |
| `src/upgrade/MarketConfigV2.sol` | 100.00% (6/6) | 100.00% (4/4) | 0.00% (0/2) | 100.00% (2/2) |
| `src/utils/AssemblyMath.sol` | 66.67% (8/12) | 66.67% (8/12) | 50.00% (4/8) | 100.00% (2/2) |
| `src/vault/FeeVault.sol` | 100.00% (2/2) | 100.00% (1/1) | 100.00% (0/0) | 100.00% (1/1) |
| `test/invariant/invariant.t.sol` | 100.00% (30/30) | 95.35% (41/43) | 83.33% (10/12) | 100.00% (5/5) |
| Total | 63.09% (188/298) | 55.48% (172/310) | 23.46% (19/81) | 93.22% (55/59) |

## Test Summary

The same coverage run executed **106 tests**, all passing.

```text
Ran 12 test suites in 92.45s: 106 tests passed, 0 failed, 0 skipped.
```
