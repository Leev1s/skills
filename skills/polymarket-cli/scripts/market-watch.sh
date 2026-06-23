#!/usr/bin/env bash
# market-watch.sh — poll midpoint price for a market
#
# Usage:
#   ./market-watch.sh <CONDITION_ID> [INTERVAL_SEC] [SIDE]
#
# Defaults: 10s interval, buy side. Press Ctrl-C to stop.

set -uo pipefail

CID="${1:?usage: $0 <CONDITION_ID> [INTERVAL_SEC] [SIDE]}"
INTERVAL="${2:-10}"
SIDE="${3:-buy}"

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

polymarket clob market "$CID" -o json > "$TMP"

TOKEN=$(python3 - "$TMP" <<'PYEOF'
import sys, json
with open(sys.argv[1]) as f:
    d = json.load(f)
toks = d.get("tokens") or []
if not toks:
    sys.exit("no tokens in CLOB market")
print(toks[0]["token_id"])
PYEOF
)

if [[ -z "$TOKEN" ]]; then
  echo "could not resolve token for $CID" >&2
  exit 1
fi

echo "watching $CID"
echo "  token:    $TOKEN"
echo "  side:     $SIDE"
echo "  interval: ${INTERVAL}s"
echo

trap 'rm -f "$TMP"; echo; echo "(stopped)"' INT TERM

while true; do
  TS=$(date +%H:%M:%S)
  P=$(polymarket clob price --side "$SIDE" "$TOKEN" -o json 2>/dev/null \
      | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('price', '—'))
except Exception:
    print('—')
" 2>/dev/null || echo "—")
  printf "%s  side=%-4s  price=%s\n" "$TS" "$SIDE" "$P"
  sleep "$INTERVAL"
done
