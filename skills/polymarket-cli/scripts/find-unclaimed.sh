#!/usr/bin/env bash
# find-unclaimed.sh — list positions needing `ctf redeem`
#
# Usage:
#   ./find-unclaimed.sh [ADDRESS]
#
# Prints one line per unique redeemable condition:
#   polymarket ctf redeem --condition 0xabc...   # Market Title (12.34 shares)

set -uo pipefail

if [[ $# -ge 1 ]]; then
  ADDR="$1"
else
  ADDR=$(polymarket wallet show -o json \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['proxy_wallet'])")
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

polymarket data positions "$ADDR" -o json > "$TMP"

python3 - "$TMP" <<'PYEOF'
import sys, json
with open(sys.argv[1]) as f:
    ps = json.load(f)
seen = {}
total_shares = 0.0
total_cost = 0.0
for p in ps:
    if not p.get("redeemable"):
        continue
    c = p["condition_id"]
    if c in seen:
        continue
    seen[c] = p
    total_shares += float(p["size"])
    total_cost += float(p["initial_value"])

if not seen:
    print("(no redeemable positions)", file=sys.stderr)
    sys.exit(0)

for c, p in seen.items():
    title = p["title"]
    size = float(p["size"])
    cost = float(p["initial_value"])
    print(f"polymarket ctf redeem --condition {c}    # {title} ({size:.2f} shares, cost ${cost:.2f})")

print(file=sys.stderr)
print(f"unique conditions: {len(seen)}", file=sys.stderr)
print(f"winning shares:    {total_shares:.4f}", file=sys.stderr)
print(f"cost basis:        ${total_cost:.2f}", file=sys.stderr)
print(f"payout at $1.00:   ${total_shares:.2f}", file=sys.stderr)
print(f"net profit:        ${total_shares - total_cost:.2f}", file=sys.stderr)
PYEOF
