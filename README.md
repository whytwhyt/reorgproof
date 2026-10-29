# ReorgProof

**A reproducible Bitcoin Core chain-reorganization testing proof of concept.**

## Problem
Bitcoin nodes can replace their active chain when they learn of a valid
competing chain with greater cumulative proof of work. Software built around
Bitcoin needs ways to test its behavior when this happens.

## Quick start
1. Obtain trusted Bitcoin Core binaries for your platform.
2. Place the executables `bitcoind` and `bitcoin-cli` in `bitcoin-core/bin/`.
3. Run:

       ./demo/run.sh

The script creates two isolated regtest nodes. Node A mines two blocks;
Node B independently mines three. The nodes connect, and the test verifies
that A adopts B's tip and that A's previous block hashes are replaced.
Evidence is written to a timestamped directory under `evidence/`.

## What it proves
One controlled, real Bitcoin Core regtest chain replacement, verified using
RPC-reported active-chain tips and block hashes.

## What it does not prove
This is not a mainnet test, production monitoring service, comprehensive
reorganization test suite, or security certification. It does not test
deep reorgs, adversarial peers, economic incentives, or every application's
rollback behavior. See [the threat model](docs/THREAT_MODEL.md).

## Requirements
Linux, Bash, and compatible Bitcoin Core `bitcoind` and `bitcoin-cli`
binaries. The demo uses temporary data directories and dedicated local
ports. Those ports must be available.
