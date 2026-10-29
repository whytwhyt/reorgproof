# Architecture

1. **Bitcoin Core regtest nodes:** independent local chains using real
   Bitcoin Core consensus and chain-selection code.
2. **Scenario driver:** starts nodes, creates wallets, mines competing
   chains, and connects the nodes through their P2P interface.
3. **Verifier:** queries RPC for active-chain tips and block hashes;
   reports PASS only when the expected chain replacement is observed.
4. **Evidence:** stores pre-reorganization hashes and the verification
   report for inspection.

The driver orchestrates a controlled test; Bitcoin Core performs the
actual chain validation and selection.
