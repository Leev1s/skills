#!/usr/bin/env bash
# snapshot.sh - dump a wallet's full state to JSON files
#
# Usage:
#   ./snapshot.sh [ADDRESS]
#
# If ADDRESS is omitted, uses the configured proxy wallet.
# Writes to ./polymarket-snapshot-<addr>-<ts>/

set -uo pipefail

if [[ $# -ge 1 ]]; then
  ADDR="$1"
else
  ADDR=$(polymarket wallet show -o json \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['proxy_wallet'])")
fi

TS=$(date +%Y%m%d-%H%M%S)
SHORT=$(echo "$ADDR" | cut -c1-10)
OUT="polymarket-snapshot-${SHORT}-${TS}"
mkdir -p "$OUT"
echo ">> writing to $OUT/"
echo "   address: $ADDR"

fetch() {
  local label="$1"; shift
  echo "   fetching $label..."
  if "$@" -o json > "$OUT/${label}.json" 2> "$OUT/${label}.err"; then
    rm -f "$OUT/${label}.err"
  else
    echo "   ! $label failed (see ${label}.err)"
  fi
}

fetch profile    polymarket profiles get "$ADDR"
fetch positions  polymarket data positions "$ADDR"
fetch closed     polymarket data closed-positions "$ADDR"
fetch value      polymarket data value "$ADDR"
fetch traded     polymarket data traded "$ADDR"
fetch trades     polymarket data trades "$ADDR" --limit 500
fetch activity   polymarket data activity "$ADDR" --limit 100
fetch approvals  polymarket approve check "$ADDR"
fetch wallet     polymarket wallet show

# Authenticated calls (uncomment if you want them - they may trigger API-key derivation):
# fetch orders     polymarket clob orders
# fetch balance    polymarket clob balance --asset-type collateral

echo
echo ">> done."
ls -la "$OUT"
