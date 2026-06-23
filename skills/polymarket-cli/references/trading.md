# Trading

## Order of operations (first time)

1. `wallet create` or `wallet import <KEY>` — generates/imports the EOA.
2. `polymarket bridge supported-assets` then `bridge deposit <PROXY>` — get a deposit address. Send USDC.
3. `polymarket approve set` — issues missing approvals. Verify with `approve check <PROXY>`.
4. Trade: `clob create-order` / `clob market-order` / `ctf split`.
5. After market resolution: `ctf redeem --condition <CID>` for winning shares.

The EOA signs, the Gnosis Safe executes. EOA needs a small POL balance for gas.

## The 6 approvals

| Contract | Required for |
|---|---|
| CTF Exchange | `clob create-order` (non-neg-risk) |
| Neg Risk Exchange | `clob create-order` (neg-risk) |
| Neg Risk Adapter | neg-risk trading |
| Conditional Tokens | `ctf split` / `merge` |
| CTF Collateral Adapter | `ctf redeem` (non-neg-risk) |
| Neg Risk CTF Collateral Adapter | `ctf redeem-neg-risk` |

`approve set` only issues the missing ones.

## Order types

`GTC` (default), `GTD` (with expiry), `FOK` (fill-or-kill), `FAK` (fill-and-kill).

- `create-order` takes `--price` + `--size` (shares).
- `market-order` takes `--amount` (pUSD for buy, shares for sell) + `--order-type FOK|FAK`.

## `clob` vs `ctf` — when

- **`clob`** for normal trading through the order book.
- **`ctf split`** to mint YES+NO directly from pUSD (liquidity provision, long-both-sides).
- **`ctf merge`** when `data positions` shows `mergeable: true` and you want to unwind before resolution.
- **`ctf redeem`** after resolution, one call per condition, converts winning shares → pUSD at $1.00 each.
- **`ctf redeem-neg-risk`** for multi-outcome events (elections). Pass `--amounts "n1,n2,..."` per outcome index set.

## Resolved but $0 — the trap

`data positions` shows `current_value: 0` and `cur_price: 0` for winning shares of resolved markets. CLOB endpoints return 404. The shares are still on the wallet as ERC1155 tokens. `polymarket ctf redeem --condition <CID>` converts them. Always check `redeemable: true` first.

Combined PnL for a wallet = `closed.realized_pnl + Σ (open.size × $1 − open.initial_value)` for `redeemable: true` positions, plus `open.cash_pnl` for unresolved ones.

## Constraints

- Min order: 5 shares (`orderMinSize: "5"` on most markets).
- Tick size: check with `clob tick-size <TOKEN>`.
- Fee rate: `clob fee-rate <TOKEN>`.
- `--post-only` makes a limit order maker-only.

## Don't

- Don't drain EOA's POL — orders will fail at signing.
- Don't reuse this key elsewhere.
- Don't expect market orders to fill in illiquid markets.
- Don't `wallet reset` without backing up the seed.
