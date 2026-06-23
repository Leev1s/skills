# Analytics & Diagnostics

## Environment

```bash
polymarket --version
polymarket status                 # public API
polymarket clob ok                # CLOB API
polymarket clob geoblock          # {"blocked": bool, "ip": ..., "country": ...}
polymarket clob time              # server clock (drift check)
```

## Read endpoints — when to use which

| Goal | Command |
|---|---|
| Live value of all open positions | `data value <ADDR>` |
| Per-position detail (cost, PnL, redeemability) | `data positions <ADDR>` |
| Historical PnL per closed position | `data closed-positions <ADDR>` |
| How many unique markets this wallet has ever touched | `data traded <ADDR>` |
| Trade tape (BUY/SELL, price, size, ts, tx hash) | `data trades <ADDR> --limit N` |
| On-chain events (TRADE / REDEEM / SPLIT / MERGE) | `data activity <ADDR> --limit N` |
| Top holders of one side of a market | `data holders <CONDITION_ID> --limit N` |
| Open interest for a market | `data open-interest <CONDITION_ID>` |
| Live volume time-series for an event | `data volume <EVENT_ID>` |
| Global top traders | `data leaderboard --period {day,week,month,all} --order-by {pnl,vol}` |
| Builder-attributed top traders / volume | `data builder-leaderboard`, `data builder-volume` |
| CLOB-side market metadata (tokens, tick, fee, neg-risk) | `clob market <CONDITION_ID>` |
| Order book for a token | `clob book <TOKEN_ID>` (404 if market closed) |
| Price history (time series) | `clob price-history <TOKEN_ID> --interval {1m,1h,6h,1d,1w,max}` |

## Field reference (data endpoints)

All snake_case. Numbers are returned as **strings** to preserve precision — cast to `float` in python or use `bc`/`jq` filters when needed.

### `data positions` per item

| Field | Type | Notes |
|---|---|---|
| `asset` | string (big int) | ERC1155 token ID — the outcome share |
| `condition_id` | 0x 32-byte | Market condition |
| `outcome` | string | "Yes" / "No" / "Up" / "Down" / team name / etc. |
| `outcome_index` | int | 0 or 1 for binary; higher for multi-outcome |
| `size` | string (decimal) | Shares held |
| `avg_price` | string (decimal) | Cost basis per share |
| `cur_price` | string (decimal) | 0 for closed markets |
| `current_value` | string (decimal) | `size × cur_price` |
| `initial_value` | string (decimal) | `size × avg_price` |
| `cash_pnl` | string (decimal) | `current_value − initial_value` |
| `percent_pnl` | string | |
| `realized_pnl` | string | 0 for open positions |
| `percent_realized_pnl` | string | |
| `redeemable` | bool | true → call `ctf redeem` |
| `mergeable` | bool | true → both sides held; can `ctf merge` |
| `negative_risk` | bool | multi-outcome event grouping |
| `title`, `event_slug`, `slug` | string | display fields |
| `icon` | URL | |
| `event_id` | string (numeric) | |
| `opposite_asset` | string (big int) | the other side's token ID |
| `opposite_outcome` | string | the other side's name |
| `proxy_wallet` | 0x 20-byte | which Safe this came from |
| `end_date` | ISO date | |
| `transaction_hash` | 0x 32-byte | only on the buy/sell that created the position |

### `data trades` per item

| Field | Type | Notes |
|---|---|---|
| `side` | "BUY" / "SELL" | |
| `price` | string (decimal) | per share, 0–1 |
| `size` | string (decimal) | shares |
| `timestamp` | int | unix seconds |
| `transaction_hash` | 0x 32-byte | |
| `asset`, `condition_id`, `outcome`, `outcome_index` | as above | |
| `title`, `slug`, `event_slug` | display | |
| `name`, `pseudonym` | profile info of *the trader* (always this wallet) | |
| `proxy_wallet` | 0x 20-byte | |

`usdc_size` is **not** in the trade record. Compute notional: `price * size`.

### `data activity` per item

Same as trades plus:

| Field | Type | Notes |
|---|---|---|
| `activity_type` | TRADE / REDEEM / SPLIT / MERGE / ... | |
| `usdc_size` | string (decimal) | only present on REWARD / some types; **not** on plain TRADE |
| `bio` | string or null | profile bio at time of activity |

`size` is in **shares** for TRADE, in **pUSD** for REDEEM / SPLIT / MERGE.

## Recipes

### Lifetime PnL for a wallet (open + closed + unclaimed)

```bash
ADDR=<proxy>
python3 <<PY
import json, subprocess
def j(cmd):
    return json.loads(subprocess.check_output(cmd + ["-o","json"]))

closed = j(["polymarket","data","closed-positions","$ADDR"])
open_  = j(["polymarket","data","positions","$ADDR"])

realized  = sum(float(p.get("realized_pnl", 0) or 0) for p in closed)
open_pnl  = sum(float(p.get("cash_pnl",     0) or 0) for p in open_)
unclaimed = sum(float(p.get("size", 0) or 0) - float(p.get("initial_value", 0) or 0)
                for p in open_ if p.get("redeemable"))

print(f"realized PnL:       \${realized:>10.2f}")
print(f"open unrealized:    \${open_pnl:>10.2f}")
print(f"unclaimed wins:     \${unclaimed:>10.2f}   (call ctf redeem)")
print(f"TOTAL:              \${realized+open_pnl+unclaimed:>10.2f}")
PY
```

### Cost basis from trade tape

```bash
ADDR=<proxy>
polymarket data trades "$ADDR" --limit 200 -o json | python3 -c '
import sys, json
trades = json.load(sys.stdin)
buy  = sum(float(t["price"]) * float(t["size"]) for t in trades if t["side"] == "BUY")
sell = sum(float(t["price"]) * float(t["size"]) for t in trades if t["side"] == "SELL")
print(f"BUY  notional:  ${buy:.2f}")
print(f"SELL notional:  ${sell:.2f}")
print(f"net deployed:   ${buy - sell:.2f}")
print(f"trades:         {len(trades)}")
'
```

### Trade mix by category

Categories can be inferred from the slug prefix (`btc-updown`, `fifwc`, `atp`, `wta`, `f1`, `fl1`, etc.):

```bash
polymarket data trades "$ADDR" --limit 200 -o json | python3 -c '
import sys, json
from collections import Counter
trades = json.load(sys.stdin)
def cat(slug):
    for k in ("btc-updown","fifwc","atp","wta","f1","fl1","epl","ucl"):
        if k in slug: return k
    return "other"
c = Counter(cat(t["slug"]) for t in trades)
for k, n in c.most_common(): print(f"{k:12s} {n}")
'
```

### Order-book snapshot

```bash
TOKEN=<id>
polymarket clob book "$TOKEN" -o json | python3 -c '
import sys, json
b = json.load(sys.stdin)
print("bids:")
for lvl in b.get("bids", [])[:5]:
    print(f"  {lvl[\"price\"]:>6}  {lvl[\"size\"]:>10}")
print("asks:")
for lvl in b.get("asks", [])[:5]:
    print(f"  {lvl[\"price\"]:>6}  {lvl[\"size\"]:>10}")
'
```

### Profile lookup

```bash
ADDR=<address>
polymarket profiles get "$ADDR" -o json | python3 -c '
import sys, json
p = json.load(sys.stdin)
print(f"pseudonym: {p.get(\"pseudonym\")}")
print(f"name:      {p.get(\"name\")}")
print(f"joined:    {p.get(\"createdAt\")}")
print(f"verified:  {p.get(\"verifiedBadge\")}")
'
```

### Leaderboard top 10 by PnL (all-time)

```bash
polymarket data leaderboard --period all --order-by pnl --limit 10 -o json | \
  python3 -c 'import sys, json
for r in json.load(sys.stdin):
    print(f"#{r[\"rank\"]:>2}  ${float(r[\"pnl\"):>12.0f}  ${float(r[\"volume\"]):>12.0f}  {r[\"user_name\"]}  {r[\"proxy_wallet\"]}")'
```

## Detecting patterns

A few quick signals useful for wallet forensics:

- **Grinder** — many tiny BUY orders on the same kind of market slug (`btc-updown-5m-*`).
- **Insider / early** — large single BUY on a low-liquidity market, low time-to-resolution.
- **Sniper** — BUY very close to the close time of a short-duration market.
- **Market maker** — both BUY and SELL on the same market, similar size.
- **Neg-risk player** — multiple positions in the same `event_id` with different `outcome_index`.

Filter on the `data trades` or `data positions` records by these patterns to pull a per-wallet profile.
