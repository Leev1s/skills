---
name: polymarket-cli
description: "Use the `polymarket` CLI on this machine for prediction-market queries and trading. Triggers on: polymarket, Polymarket CLI, CLOB API, prediction market trading, CTF split/merge/redeem, proxy wallet (Gnosis Safe) on Polygon, pUSD, neg-risk markets, sports/F1/crypto/political markets, Polymarket leaderboards, positions, redeemable winnings, order book, limit/market orders, market resolution, $POLY, Feline-Tenet (or any pseudonymous Polymarket profile). Use whenever the user asks to read or trade Polymarket markets, events, tags, series, comments, profiles, CLOB prices/books/orderbook, place/cancel orders, redeem winning shares, bridge assets, or analyze any Polymarket wallet from the terminal."
---

# polymarket CLI

The `polymarket` binary is installed at `/Users/lev1s/.cargo/bin/polymarket` (also on `PATH`). Version 0.1.4. CLOB API + public APIs are live; geoblock status can be checked with `polymarket clob geoblock`.

The CLI is the fastest way to read, trade, and analyze Polymarket without leaving the terminal. Use it whenever the user wants prediction-market data or actions, especially from the command line or in scripts.

## Quick check (run first)

```bash
command -v polymarket
polymarket --version
polymarket status              # public API health
polymarket clob ok             # CLOB API health
polymarket clob geoblock       # region restrictions
```

If `command -v polymarket` is empty, install with `cargo install polymarket` (Rust toolchain required) — see [references/setup.md](references/setup.md).

## Wallet context (this machine)

The wallet is already configured. Read it before doing anything auth-sensitive:

```bash
polymarket wallet show
```

Reference output:

- EOA: `0x98Fc9A9739c84eF5C672accc68B274DD44b9cc55`
- Proxy (Gnosis Safe): `0x21B1E7fD66aDE3a697cd06c293568Ef53473DDc2`
- Signature type: `proxy`
- Config: `/Users/lev1s/.config/polymarket/config.json`
- Chain: Polygon (`chain_id: 137`)
- Collateral: pUSD (`0xC011a7E12a19f7B1f670d46F03B03f3342E82DFB`)
- Profile pseudonym: **Feline-Tenet** (`name=b03ce8`)

For all read commands that take an address (e.g. `data positions`, `data trades`, `profiles get`), pass the **proxy wallet** — that's where positions and balances actually live. The EOA only signs transactions.

## Command map

| Command | Auth | Purpose |
|---|---|---|
| `markets list / get / search / tags` | – | Browse markets |
| `events list / get / tags` | – | Multi-market events |
| `tags list / get / related / related-tags` | – | Browse the tag taxonomy |
| `series list / get` | – | Recurring event families |
| `comments list / get / by-user` | – | Market/event discussion |
| `profiles get <addr>` | – | Public pseudonym + bio + joined date |
| `sports list / market-types / teams` | – | Sports metadata |
| `clob price / book / midpoint / spread / last-trade / market(s) / sampling-markets / tick-size / fee-rate / neg-risk / price-history / time / geoblock / ok / batch-prices / midpoints / spreads / books / last-trades` | – | CLOB reads |
| `data positions / closed-positions / value / traded / trades / activity / holders / open-interest / volume / leaderboard / builder-leaderboard / builder-volume` | – (addr arg) | Analytics |
| `wallet create / import / address / show / reset` | – | Wallet lifecycle |
| `setup` | – | Guided first-time setup |
| `approve check / set` | – (check) / writes (set) | Contract approvals |
| `clob create-order / market-order / cancel / cancel-orders / cancel-all / cancel-market / orders / order / post-orders / trades / balance / update-balance / api-keys / account-status` | **yes** | Trading + account |
| `ctf split / merge / redeem / redeem-neg-risk / condition-id / collection-id / position-id` | **yes** | Position management |
| `bridge deposit / supported-assets / status` | – | Cross-chain deposits |
| `shell` | – | Interactive REPL |
| `status` / `upgrade` | – | Health / self-update |

For the full reference (every flag + sample JSON), read [references/commands.md](references/commands.md). For trading mechanics (approvals, signing model, order types, redemption flow), read [references/trading.md](references/trading.md). For analytics recipes and field shape, read [references/analytics.md](references/analytics.md). For shell, JSON output, env vars, exit codes, and scripting patterns, read [references/scripting.md](references/scripting.md).

## Output format

All commands accept `-o json` (or `-o table`, default `table`). Use `-o json` for scripting and any time you want to pipe into `jq` or `python3`. Field naming is **snake_case** throughout the data endpoints; top-level wrapper keys sometimes differ (e.g. `{"data": [...]}` with a `next_cursor` for some endpoints, plain arrays for others). Always check the shape with the actual command before parsing.

## Core workflows

### 1. Wallet snapshot

```bash
ADDR=$(polymarket wallet show -o json | python3 -c "import sys,json;print(json.load(sys.stdin)['proxy_wallet'])")

polymarket data positions "$ADDR" -o json
polymarket data closed-positions "$ADDR" -o json
polymarket data value "$ADDR" -o json
polymarket data traded "$ADDR" -o json
polymarket data trades "$ADDR" --limit 200 -o json
polymarket data activity "$ADDR" --limit 25 -o json
```

A reusable version is in `scripts/snapshot.sh`.

### 2. Find and redeem winning positions

Resolved markets where the user holds winning shares show as `redeemable: true` in `data positions`. Each winning share redeems at $1.00 worth of pUSD. Convert shares back to pUSD with:

```bash
polymarket ctf redeem --condition <CONDITION_ID>
```

List every unclaimed condition and emit a redeem command for each:

```bash
polymarket data positions "$ADDR" -o json | python3 -c '
import sys, json
ps = json.load(sys.stdin)
seen = set()
for p in ps:
    c = p["condition_id"]
    if c in seen: continue
    seen.add(c)
    print(f"polymarket ctf redeem --condition {c}    # {p[\"title\"]} ({float(p[\"size\"]):.2f} shares)")
'
```

The bundled `scripts/find-unclaimed.sh` does this in one shot.

### 3. Place a limit order

```bash
# 1. Find a market + token ID
polymarket markets search "btc 100k 2026" -o json
polymarket clob market <CONDITION_ID> -o json   # gives you token IDs

# 2. (first time only) approve the CLOB contracts
polymarket approve set

# 3. Place the order (this is an on-chain tx via the proxy Safe)
polymarket clob create-order \
  --token <TOKEN_ID> --side buy --price 0.55 --size 10 \
  --order-type GTC
```

Order types: `GTC` (default, sits on the book), `FOK` (fill or kill), `GTD` (good til date), `FAK` (fill and kill). For market orders use `polymarket clob market-order` — `--amount` is pUSD for buys, shares for sells.

### 4. Watch a market

```bash
TOKEN=$(polymarket clob market <CONDITION_ID> -o json | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['tokens'][0]['token_id'])")
while true; do
  polymarket clob midpoint "$TOKEN" -o json
  sleep 10
done
```

A reusable version is in `scripts/market-watch.sh`.

### 5. Browse hot markets

```bash
polymarket markets list --order volume_num --limit 20 -o json
polymarket events list --tag politics --order volume --limit 20 -o json
polymarket data leaderboard --period week --order-by pnl --limit 10 -o json
```

## Field naming gotchas

- **Asset IDs** are giant unsigned integers (256-bit), not 0x-prefixed. Pass them as strings — bash and python both handle this fine; do **not** coerce to a JS Number.
- **Condition IDs** are `0x` + 32 bytes hex. They identify a market; one market can have multiple outcomes, each with its own asset ID.
- **`slug`** identifies the human-readable URL form (`new-rhianna-album-before-gta-vi-926`). Use slugs when sharing links.
- **`event_slug` vs `slug`**: an *event* groups related markets (e.g. an election with one market per state). `event_slug` = parent event, `slug` = the individual market.
- **`clobTokenIds`** in market data is a JSON-encoded string array of asset IDs — parse it.
- **`outcomePrices`** and **`outcomes`** are also JSON-encoded strings in market data — parse before using.
- **snake_case everywhere** in `data`, `positions`, `trades` (despite the Polymarket web UI using camelCase).

## "Resolved but $0" — what it means

`polymarket data positions` returns positions with `current_value: 0` and `cur_price: 0` even when the user won the bet. This is normal for **resolved** markets:

- The market is `closed: true`, `enable_order_book: false`, `accepting_orders: false`
- CLOB `price` / `book` / `midpoint` endpoints return 404 for the asset
- The winning shares are still on the user's proxy wallet as ERC1155 tokens
- They must be converted back to pUSD with `polymarket ctf redeem --condition <CID>` — one redeem per condition ID

So **always check `redeemable: true` first** when surveying a wallet. The combined PnL is `closed-positions.realized_pnl + Σ (positions.size × $1 − positions.initial_value)` for `redeemable: true` positions.

## Safety

- `polymarket approve set` and `ctf *` and `clob create-order` / `cancel*` are real on-chain transactions (signed by EOA, executed via the proxy Safe). Each pays gas on Polygon.
- The private key lives in `~/.config/polymarket/config.json` (mode-restricted by the CLI). Do not echo it; if asked to display the wallet, use `polymarket wallet show` which only reveals the address.
- Geo-restricted regions are blocked by the CLOB. Check with `polymarket clob geoblock` before assuming orders will work.
- `--signature-type` defaults to `proxy` (correct for any wallet created by `wallet create`). Use `eoa` only if you explicitly bypassed the Safe; use `gnosis-safe` for already-deployed Safe wallets you imported.

## Bundled scripts

- `scripts/snapshot.sh <ADDRESS>` — full wallet snapshot to JSON files in `./polymarket-snapshot-<addr>-<ts>/`
- `scripts/find-unclaimed.sh <ADDRESS>` — list all redeemable conditions with redeem commands
- `scripts/market-watch.sh <CONDITION_ID> [INTERVAL_SEC]` — poll midpoint price

## Updating this skill

The CLI has a built-in self-updater. When a new version ships:

```bash
polymarket upgrade
polymarket --version
```

Then re-run any command whose `--help` changed and update the affected reference file. The command map at the top of this file should match the output of `polymarket --help`.
