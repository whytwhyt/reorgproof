#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/bitcoin-core/bin"
[[ -x "$BIN/bitcoind" && -x "$BIN/bitcoin-cli" ]] || {
  echo "ERROR: Bitcoin Core binaries missing: $BIN"; exit 1;
}
E="$ROOT/evidence/demo-$(date +%Y%m%d-%H%M%S)"
R="$(mktemp -d "$ROOT/demo/runtime.XXXXXX")"
A="$R/a"; B="$R/b"
mkdir -p "$A" "$B" "$E"

a() { "$BIN/bitcoin-cli" -regtest -datadir="$A" -rpcport=18543 "$@"; }
b() { "$BIN/bitcoin-cli" -regtest -datadir="$B" -rpcport=18546 "$@"; }

cleanup() {
  rc=$?
  trap - EXIT
  a stop >/dev/null 2>&1 || true
  b stop >/dev/null 2>&1 || true
  if [[ $rc -ne 0 ]]; then
    [[ -f "$A/regtest/debug.log" ]] && cp "$A/regtest/debug.log" "$E/node-a-debug.log" || true
    [[ -f "$B/regtest/debug.log" ]] && cp "$B/regtest/debug.log" "$E/node-b-debug.log" || true
    echo "FAILED. Diagnostics: $E"
  fi
  rm -rf "$R"
  exit "$rc"
}
trap cleanup EXIT

ready() {
  for _ in $(seq 1 30); do
    "$@" getblockchaininfo >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

echo "[1/5] Starting isolated Bitcoin Core nodes..."
"$BIN/bitcoind" -regtest -datadir="$A" -daemon \
  -port=18544 -rpcport=18543 -bind=127.0.0.1:18544 \
  -rpcbind=127.0.0.1 -discover=0 -dnsseed=0 >/dev/null
"$BIN/bitcoind" -regtest -datadir="$B" -daemon \
  -port=18547 -rpcport=18546 -bind=127.0.0.1:18547 \
  -rpcbind=127.0.0.1 -discover=0 -dnsseed=0 >/dev/null
ready a || { echo "Node A failed to start"; exit 1; }
ready b || { echo "Node B failed to start"; exit 1; }

echo "[2/5] Creating wallets and competing chains..."
a createwallet reorg_a >/dev/null
b createwallet reorg_b >/dev/null
AA=$(a -rpcwallet=reorg_a getnewaddress)
BA=$(b -rpcwallet=reorg_b getnewaddress)
a generatetoaddress 2 "$AA" >/dev/null
b generatetoaddress 3 "$BA" >/dev/null

OLDTIP=$(a getbestblockhash)
OLD1=$(a getblockhash 1)
OLD2=$(a getblockhash 2)
BTIP=$(b getbestblockhash)
{
  echo "Node A old tip: $OLDTIP"
  echo "Node A old height 1: $OLD1"
  echo "Node A old height 2: $OLD2"
  echo "Node B tip: $BTIP"
} > "$E/before.txt"

echo "[3/5] Connecting the nodes..."
a addnode 127.0.0.1:18547 onetry >/dev/null

echo "[4/5] Verifying actual chain replacement..."
PASS=0
for _ in $(seq 1 30); do
  [[ "$(a getbestblockhash 2>/dev/null || true)" == "$BTIP" ]] && {
    PASS=1; break;
  }
  sleep 1
done
[[ "$PASS" == 1 ]] || { echo "FAIL: Node A did not adopt Node B's tip"; exit 1; }

NEW1=$(a getblockhash 1)
NEW2=$(a getblockhash 2)
NEWTIP=$(a getbestblockhash)
[[ "$OLDTIP" != "$NEWTIP" && "$OLD1" != "$NEW1" && "$OLD2" != "$NEW2" ]] || {
  echo "FAIL: Expected block replacement not verified"; exit 1;
}
{
  echo "RESULT: PASS"
  echo "Network: Bitcoin Core regtest (not mainnet)"
  echo "Node A old tip: $OLDTIP"
  echo "Node A new tip: $NEWTIP"
  echo "Node B tip: $BTIP"
  echo "Old height 1: $OLD1"
  echo "New height 1: $NEW1"
  echo "Old height 2: $OLD2"
  echo "New height 2: $NEW2"
  echo "Final height: $(a getblockcount)"
} | tee "$E/report.txt"

echo "[5/5] PASS. Evidence: $E"
