---
name: polymarket-cli
description: "Use the `polymarket` CLI on this machine for prediction-market queries and trading. Triggers on: polymarket, Polymarket CLI, CLOB API, prediction market trading, CTF split/merge/redeem, proxy wallet (Gnosis Safe) on Polygon, pUSD, neg-risk markets, sports/F1/crypto/political markets, Polymarket leaderboards, positions, redeemable winnings, order book, limit/market orders, market resolution. Use whenever the user asks to read or trade Polymarket markets, events, tags, series, comments, profiles, CLOB prices/books/orderbook, place/cancel orders, redeem winning shares, bridge assets, or analyze any Polymarket wallet from the terminal."
---

# polymarket CLI

`/Users/lev1s/.cargo/bin/polymarket` (also on `PATH`), v0.1.4. CLOB and public APIs are live; check `polymarket clob geoblock` for region restrictions. Trust `polymarket <cmd> --help` first — this skill points to it, doesn't re-type it.

## Quick check

```bash
command -v polymarket
polymarket --version
polymarket status
polymarket clob ok
polymarket clob geoblock
```

Install if missing: `cargo install polymarket`.

## Wallet on this machine

```bash
polymarket wallet show
```

- EOA: `0x98Fc9A9739c84eF5C672accc68B274DD44b9cc55`
- Proxy (Gnosis Safe): `0x21B1E7fD66aDE3a697cd06c293568Ef53473DDc2`
- Signature type: `proxy`
- Config: `~/.config/polymarket/config.json`, chain Polygon (137), collateral pUSD
- Profile pseudonym: **Feline-Tenet**

For reads that take an address (`data positions`, `data trades`, `profiles get`, etc.) pass the **proxy wallet** — that's where positions and balances live. The EOA only signs.

## Command map

| Command | Auth | Purpose |
|---|---|---|
| `markets list / get / search / tags` | – | Browse markets |
| `events list / get / tags` | – | Multi-market events |
| `tags`, `series`, `comments`, `profiles get`, `sports` | – | Taxonomy + profile + sport metadata |
| `clob price / book / midpoint / spread / last-trade / market(s) / tick-size / fee-rate / neg-risk / price-history / sampling-markets / time / geoblock / ok` | – | CLOB reads |
| `data positions / closed-positions / value / traded / trades / activity / holders / open-interest / volume / leaderboard / builder-leaderboard / builder-volume` | – | Analytics (pass proxy as ADDRESS) |
| `wallet create / import / address / show / reset` | – | Wallet lifecycle |
| `setup` | – | Guided first-time setup |
| `approve check / set` | check: – / set: writes | Six contract approvals |
| `clob create-order / market-order / cancel / cancel-orders / cancel-all / cancel-market / orders / order / balance / update-balance / api-keys / account-status` | **yes** | Trading + account |
| `ctf split / merge / redeem / redeem-neg-risk / condition-id / collection-id / position-id` | **yes** | Position management |
| `bridge deposit / supported-assets / status` | – | Cross-chain deposits |
| `shell` | – | Interactive REPL |
| `status` / `upgrade` | – | Health / self-update |

For full flag reference, run `polymarket <cmd> --help` against the live binary.

## Core workflows

### Wallet snapshot

```bash
ADDR=$(polymarket wallet show -o json | python3 -c "import sys,json; print(json.load(sys.stdin)['proxy_wallet'])")
polymarket data positions "$ADDR" -o json
polymarket data closed-positions "$ADDR" -o json
polymarket data trades "$ADDR" --limit 500 -o json
```

See `scripts/snapshot.sh` for a one-shot dump to JSON files.

### Find and redeem winning positions

Resolved markets where the user holds winning shares show as `redeemable: true` in `data positions`. Each winning share redeems at $1.00 of pUSD:

```bash
polymarket ctf redeem --condition <CONDITION_ID>
```

List every unclaimed condition in one shot: `scripts/find-unclaimed.sh` (or the one-liner in [references/trading.md](references/trading.md#resolved-but-0--the-trap)).

### Place a limit order

```bash
CID=$(polymarket markets search "btc 100k end of 2026" -o json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['condition_id'])")
TOKEN=$(polymarket clob market "$CID" -o json | python3 -c "import sys,json; print(json.load(sys.stdin)['tokens'][0]['token_id'])")
polymarket clob create-order --token "$TOKEN" --side buy --price 0.55 --size 10
```

First time only: `polymarket approve set` (sends txs). Order types: `GTC` (default), `GTD`, `FOK`, `FAK`. For market orders use `clob market-order` with `--amount` (pUSD for buy, shares for sell).

### Watch a market

`scripts/market-watch.sh <CONDITION_ID> [INTERVAL_SEC]` (default 10s, buy side).

## Field gotchas

- **Asset IDs** are 256-bit unsigned integers (not `0x`-prefixed). Pass as strings.
- **Condition IDs** are `0x` + 32 bytes hex. Identify a market; one market can have many outcomes, each with its own asset ID.
- `clobTokenIds`, `outcomePrices`, `outcomes` in market data are **JSON-encoded strings** — parse them.
- `event_slug` (parent event) vs `slug` (individual market).
- `data trades` does NOT include `usdc_size` — compute notional as `price × size`.

## "Resolved but $0" — the trap

`data positions` shows `current_value: 0`, `cur_price: 0` for winning shares of resolved markets. CLOB endpoints return 404. The shares are still on the wallet as ERC1155 tokens. Call `polymarket ctf redeem --condition <CID>` to convert them at $1.00 each. Always check `redeemable: true` first.

## Safety

- `approve set`, `ctf *`, `clob create-order` / `cancel*` are real on-chain txs (EOA signs, Safe executes). Each pays gas on Polygon — keep POL in the EOA.
- Private key in `~/.config/polymarket/config.json`. Use `wallet show` (never the raw config) to display.
- `--signature-type` defaults to `proxy` (correct for `wallet create`). Use `eoa` or `gnosis-safe` only if you specifically need them.

## References

- [trading.md](references/trading.md) — order of operations, approvals, order types, redeem workflow
- [analytics.md](references/analytics.md) — data endpoints, field shapes, recipes (PnL, trade mix, token lookup)
- [scripting.md](references/scripting.md) — JSON output, pagination, exit codes, env/config, rate limits

## Update this skill

```bash
polymarket upgrade
polymarket --version
```

Re-run any command whose `--help` changed and update the affected reference file. The command map at the top of this file should match `polymarket --help`.
