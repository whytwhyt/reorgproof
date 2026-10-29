# ReorgProof

**A reproducible Bitcoin Core chain-reorganization test and evidence tool.**

## Problem
Chain reorganizations are a normal property of Bitcoin: competing valid
chains can exist, and a node may replace its current chain when it learns
of a chain with more cumulative proof of work. Developers need to test
software behavior around this event rather than assume it works correctly.

## Demonstration
Run:

    ./demo/run.sh

The demo starts two isolated Bitcoin Core regtest nodes. Node A mines two
blocks; Node B independently mines three. They are then connected. The test
checks that A adopts B's tip and that A's old block hashes at heights 1 and
2 have been replaced. It writes before-and-after evidence and a PASS report
under `evidence/`.

## Scope
This is a local proof of concept, not a mainnet monitoring service, a
production security auditor, or a comprehensive reorganization test suite.
It verifies one controlled chain-replacement scenario.

## Limitations
- Regtest is a controlled local environment; it does not reproduce mainnet
  mining, network latency, adversarial peers, or real economic incentives.
- A successful test is evidence for this scenario only, not proof that all
  Bitcoin applications handle reorganizations safely.
- The demo depends on the bundled Bitcoin Core binaries being executable
  and its selected local ports being available.
- The project does not change Bitcoin consensus rules.

## Reproducibility
The script creates temporary node data directories for each run, stores
evidence in a new directory, and removes its temporary data after stopping
the nodes. Existing `regtest-a` and `regtest-b` directories are not used.
