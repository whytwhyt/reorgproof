# Threat Model and Limitations

## Assets
- Correct identification of each node's active chain tip.
- Integrity and traceability of before-and-after hash evidence.
- Clear separation of local test claims from mainnet claims.

## Assumptions
- RPC responses originate from the intended local nodes.
- The host, executables, and evidence files are not maliciously altered.
- Both nodes use compatible Bitcoin Core consensus rules and regtest settings.

## Failure conditions
The demo fails if a node cannot start, Node A fails to adopt Node B's tip
within the timeout, or the expected block-hash changes are not observed.

## Out of scope
Mainnet behavior, malicious RPC responses, compromised binaries, deep
reorganizations, adversarial network conditions, wallet recovery, and
application-specific rollback correctness.

A PASS demonstrates this controlled regtest scenario only; it is not a
production-readiness guarantee.
