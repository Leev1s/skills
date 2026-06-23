# Analytics recipes

All numbers from these endpoints are strings — cast to float. Field names are snake_case throughout.

## Lifetime PnL for a wallet

```bash
ADDR=<proxy>
python3 <<PY
import json, subprocess
def j(cmd): return json.loads(subprocess.check_output(cmd + ["-o","json"]))
closed = j(["polymarket","data","closed-positions","$ADDR"])
open_  = j(["polymarket","data","positions","$ADDR"])
realized  = sum(float(p.get("realized_pnl",0) or 0) for p in closed)
open_pnl  = sum(float(p.get("cash_pnl",0) or 0) for p in open_)
unclaimed = sum(float(p.get("size",0) or 0) - float(p.get("initial_value",0) or 0)
                for p in open_ if p.get("redeemable"))
print(f"realized:   \${realized:>10.2f}")
print(f"open PnL:   \${open_pnl:>10.2f}")
print(f"unclaimed:  \${unclaimed:>10.2f}")
print(f"TOTAL:      \${realized+open_pnl+unclaimed:>10.2f}")
PY
```

## Cost basis from trade tape

`data trades` does NOT include `usdc_size`. Compute notional as `price × size`:

```bash
polymarket data trades "$ADDR" --limit 500 -o json | python3 -c '
import sys, json
t = json.load(sys.stdin)
buy  = sum(float(x["price"])*float(x["size"]) for x in t if x["side"]=="BUY")
sell = sum(float(x["price"])*float(x["size"]) for x in t if x["side"]=="SELL")
print(f"BUY  ${buy:.2f}  SELL ${sell:.2f}  net ${buy-sell:.2f}  ({len(t)} trades)")
'
```

## Trade mix by category

Infer from slug prefix: `btc-updown`, `fifwc`, `atp`, `wta`, `f1`, `fl1`, `epl`, `ucl`.

```bash
polymarket data trades "$ADDR" --limit 500 -o json | python3 -c '
import sys, json
from collections import Counter
def cat(s):
    for k in ("btc-updown","fifwc","atp","wta","f1","fl1","epl","ucl"):
        if k in s: return k
    return "other"
print(Counter(cat(t["slug"]) for t in json.load(sys.stdin)).most_common())
'
```

## Top markets by 24h volume

```bash
polymarket markets list --order volume_num --limit 20 -o json | python3 -c '
import sys, json
for m in json.load(sys.stdin):
    print(f"${float(m[\"volume24hr\"]):>10.0f}  ${float(m[\"liquidity\"]):>10.0f}  {m[\"question\"][:60]}")
'
```

## Token ID by market slug

`clobTokenIds` and `outcomePrices` in market data are JSON-encoded strings — parse them:

```bash
polymarket markets get "btc-updown-5m-1773759000" -o json | python3 -c '
import sys, json
m = json.load(sys.stdin)
print("token IDs:", json.loads(m["clobTokenIds"]))
print("prices:   ", json.loads(m["outcomePrices"]))
'
```

## Field notes

- `data positions`: `asset` is a huge integer string (ERC1155 token ID), `cur_price: 0` for closed markets, `redeemable: true` means winning shares of a resolved market, `mergeable: true` means both YES and NO are held.
- `data trades`: per-trade fields are `side` (BUY/SELL), `price`, `size`, `timestamp` (unix s), `transaction_hash`, plus the same identity fields as positions. No `usdc_size` — compute notional.
- `data activity`: `activity_type` ∈ {TRADE, REDEEM, SPLIT, MERGE, ...}. `size` is shares for TRADE, pUSD for REDEEM/SPLIT/MERGE.
- `data holders`: returns top holders per outcome, with `amount`, `pseudonym`, `proxy_wallet`, `outcome_index`.
- `clob book` for closed markets returns 404 — the book is removed post-resolution.

## Detecting wallet patterns

- **Grinder**: many small BUYs on the same slug pattern (`btc-updown-5m-*`).
- **Sniper**: BUY very close to close time of a short-duration market.
- **Market maker**: paired BUY and SELL on the same market, similar size.
- **Neg-risk player**: multiple positions in the same `event_id` with different `outcome_index`.
