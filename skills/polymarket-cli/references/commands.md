# Full Command Reference

Every command accepts the global flags:

- `-o, --output <table|json>` (default `table`)
- `--private-key <HEX>` — overrides env var and config
- `--signature-type <eoa|proxy|gnosis-safe>` — default `proxy`
- `-h, --help`

When in doubt, run `<command> --help` against the live binary; the surface is stable but flags move between minor versions.

## Browse

### `markets list [--active t|f] [--closed t|f] [--limit N] [--offset N] [--order FIELD] [--ascending]`

Lists markets. Sort fields include `volume_num`, `liquidity_num`. Default limit 25, descending.

```bash
polymarket markets list --order volume_num --limit 5 -o json
```

### `markets get <ID|SLUG>`

Single market by numeric ID or slug. Returns full record including `clobTokenIds` (JSON-encoded array of asset IDs) and `outcomePrices` (JSON-encoded array).

### `markets search <QUERY> [--limit N]`

Search across markets, events, and profiles. Default 10 per type.

### `markets tags <ID>`

Tags applied to a specific market.

### `events list [--active t|f] [--closed t|f] [--tag SLUG] [--order FIELD] [--limit N]`

Events group related markets (e.g. a multi-outcome election). Filter by tag (`politics`, `crypto`, `sports`, etc.).

### `events get <ID|SLUG>` / `events tags <ID>`

Single event by ID/slug; tags for an event.

### `tags list / get / related / related-tags`

Tag taxonomy and relationships. Useful for discovering categories.

### `series list / get <ID>`

Recurring event families (e.g. daily crypto up/down).

### `comments list [--entity-type event|market|series] --entity-id <ID> [--limit N] [--offset N] [--order FIELD]`

Comments on any entity.

### `comments get <ID>` / `comments by-user <ADDRESS>`

Single comment or comments by a wallet.

### `profiles get <ADDRESS>`

Public profile (pseudonym, name, joined date, profile image URL, verification status).

### `sports list / market-types / teams`

Sports metadata for sports-related markets.

## CLOB reads

### `clob ok` / `clob time`

API health and server time.

### `clob geoblock`

Geo-restriction check. Returns `{"blocked": bool, "ip": "...", "country": "..."}`.

### `clob price --side <buy|sell> <TOKEN_ID>`

Price for one side of a token. **Requires `--side`**.

### `clob batch-prices / midpoints / spreads / books / last-trades`

Batch versions. Takes a list of token IDs as the argument (or via stdin, check `--help`).

### `clob midpoint / spread / last-trade <TOKEN_ID>`

Single-token summary.

### `clob book <TOKEN_ID>`

Full order book. Returns 404 when the market is closed and the book has been removed.

### `clob market <CONDITION_ID>` / `clob markets`

CLOB-side market info (tokens, minimum tick size, fees, neg-risk flag, etc.).

### `clob sampling-markets / simplified-markets / sampling-simp-markets`

Reward-eligible and reduced-detail listings.

### `clob tick-size <TOKEN_ID>` / `clob fee-rate <TOKEN_ID>` / `clob neg-risk <TOKEN_ID>`

Pricing-config lookups.

### `clob price-history <TOKEN_ID> --interval <1m|1h|6h|1d|1w|max> [--fidelity N]`

Time-series price. Default fidelity depends on interval.

## Analytics (`data`)

### `data positions <ADDRESS>`

Open positions. Fields include:

- `asset` (huge integer string) — token ID
- `condition_id` — market condition
- `outcome` / `outcome_index` — which side
- `size` — shares held
- `avg_price` — cost basis per share
- `cur_price` — current price (0 for closed markets)
- `current_value` — `size × cur_price`
- `initial_value` — total cost basis
- `cash_pnl` — `current_value − initial_value`
- `percent_pnl`
- `realized_pnl` — 0 for open positions
- `redeemable` — true if winning shares of a resolved market
- `mergeable` — true if both sides held (can `ctf merge` back to pUSD)
- `negative_risk` — multi-outcome event grouping
- `title`, `event_slug`, `slug`, `icon`

### `data closed-positions <ADDRESS>`

Same shape but `realized_pnl` is set, `current_value` and `cur_price` reflect settlement.

### `data value <ADDRESS>`

Total live position value (USD). Returns `{"user": "...", "value": "..."}`.

### `data traded <ADDRESS>`

Count of unique markets ever traded.

### `data trades <ADDRESS> [--limit N] [--offset N]`

Trade history. Fields: `side` (BUY/SELL), `price`, `size`, `timestamp` (unix seconds), `transaction_hash`, `name`, `pseudonym`, `title`, `slug`, `event_slug`, `condition_id`, `asset`, `outcome`, `outcome_index`. **`usdc_size` is not included** — compute notional as `price × size`.

### `data activity <ADDRESS> [--limit N] [--offset N]`

On-chain activity. `activity_type` ∈ {`TRADE`, `REDEEM`, `SPLIT`, `MERGE`, ...}. Includes `transaction_hash`.

### `data holders <CONDITION_ID> [--limit N]`

Top holders per outcome token. Returns `holders: [{amount, asset, outcome_index, pseudonym, proxy_wallet, ...}]`.

### `data open-interest <CONDITION_ID>`

Open interest.

### `data volume <EVENT_ID>`

Live volume time-series for an event.

### `data leaderboard [--period day|week|month|all] [--order-by pnl|vol] [--limit N] [--offset N]`

Global trader leaderboard. Fields: `rank`, `user_name`, `proxy_wallet`, `pnl`, `volume`, `profile_image`, `verified_badge`, `x_username`.

### `data builder-leaderboard` / `data builder-volume`

Builder-attributed volume (markets tagged with a builder).

## Wallet / auth

### `wallet create [--force] [--signature-type eoa|proxy|gnosis-safe]`

Generates a new random key. Default `proxy`. Overwrites existing config unless `--force` is given.

### `wallet import <KEY> [--force] [--signature-type ...]`

Imports an existing hex private key (with or without `0x` prefix).

### `wallet address` / `wallet show`

`address` returns just the address. `show` returns address + proxy wallet + config path + key source. **Use `show`, not the raw config file** — it never prints the private key.

### `wallet reset [--force]`

Wipes the config file. Destroys the local key reference — keep your seed elsewhere.

### `setup`

Interactive guided flow: imports/generates a key, deploys the proxy Safe, and sets all required approvals. Safe deployment is a real on-chain tx.

### `approve check <ADDRESS>` / `approve set`

`check` shows current approval status for the six contracts (CTF Exchange, Neg Risk Exchange, Neg Risk Adapter, Conditional Tokens, CTF Collateral Adapter, Neg Risk CTF Collateral Adapter). `set` issues missing approvals — sends one or more on-chain txs.

## CLOB writes (authenticated)

### `clob orders` / `clob order <ID>` / `clob create-order` / `clob post-orders` / `clob market-order`

`create-order` flags: `--token`, `--side {buy,sell}`, `--price`, `--size`, `--order-type {GTC,FOK,GTD,FAK}`, `--post-only`.

`market-order` flags: `--token`, `--side`, `--amount` (pUSD for buy, shares for sell), `--order-type {FOK,FAK}` (default FOK). Market orders sweep the book until filled or cancelled.

### `clob cancel <ID>` / `cancel-orders <ID1,ID2,...>` / `cancel-all` / `cancel-market --market <CID> [--asset <TOKEN_ID>]`

Cancel by ID or in bulk.

### `clob trades [--market <CID>] [--asset <TOKEN_ID>] [--cursor ...]`

Authenticated trade history filtered to this account. Use `--cursor` for pagination.

### `clob balance --asset-type {collateral,conditional} [--token <TOKEN_ID>]`

USDC/pUSD allowance and conditional token balances. `--token` required for `--asset-type conditional`.

### `clob update-balance`

Refreshes balance allowance on-chain (used when allowance shows stale).

### `clob api-keys / create-api-key / delete-api-key` / `clob account-status`

API key management and account status.

### Rewards

`clob notifications`, `delete-notifications`, `rewards`, `earnings [--date YYYY-MM-DD]`, `earnings-markets`, `reward-percentages`, `current-rewards`, `market-reward`, `order-scoring`, `orders-scoring`.

## CTF (position management)

### `ctf split --condition <CID> --amount <pUSD> [--partition 1,2]`

Convert pUSD into equal YES + NO outcome tokens. Default partition `1,2` for binary markets.

### `ctf merge --condition <CID> --amount <pUSD>`

Burn equal YES + NO shares and reclaim pUSD. Use when `data positions` shows `mergeable: true`.

### `ctf redeem --condition <CID>`

Burn winning shares of a resolved market and reclaim $1.00 per share in pUSD. **One redeem per condition** — covers all winning shares for that market.

### `ctf redeem-neg-risk --condition <CID> --amounts <n1,n2,...>`

For multi-outcome neg-risk events (e.g. election with many candidates), specify the amount per outcome index set.

### `ctf condition-id --oracle <0x> --question <0x> --outcomes <N>`

Compute condition ID from oracle, question ID, and outcome count.

### `ctf collection-id --condition <CID> --index-set <N> [--parent-collection <0x>]`

Compute collection ID.

### `ctf position-id --collection <0x> [--collateral <0x>]`

Compute ERC1155 token ID.

## Bridge

### `bridge supported-assets`

List chains and tokens you can deposit (EVM, Solana, Bitcoin).

### `bridge deposit <ADDRESS>`

Get per-chain deposit addresses tied to your Polymarket wallet. Send USDC (or the supported asset) to the deposit address; it bridges and credits your proxy.

### `bridge status <ADDRESS>`

Check deposit status.

## Misc

### `shell`

Interactive REPL — same commands, no need to repeat `polymarket`. `exit` to leave.

### `status`

Public API health.

### `upgrade`

Self-update to the latest release.
