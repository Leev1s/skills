# Trading & Position Management

## Order of operations for a brand-new wallet

1. **Create a wallet** (or import an existing key). The CLI generates the EOA and prepares a proxy Safe.

   ```bash
   polymarket wallet create
   # or
   polymarket wallet import 0xYOUR_KEY
   ```

   Default signature type is `proxy` — keep it.

2. **Bridge USDC to Polygon** in your proxy's name. The easiest path:

   ```bash
   polymarket bridge supported-assets
   polymarket bridge deposit "$(polymarket wallet show -o json | python3 -c 'import sys,json;print(json.load(sys.stdin)["proxy_wallet"])')"
   ```

   Then send USDC (on the right chain) to the deposit address. Wait for it to land.

3. **Set approvals** — the Safe must allow the CLOB and CTF contracts to move pUSD on its behalf.

   ```bash
   polymarket approve set
   ```

   Inspect first: `polymarket approve check <PROXY>`.

4. **Trade.** The CLI signs with the EOA, the proxy Safe executes. Each `create-order` / `ctf *` is a real on-chain transaction that costs gas.

5. **After resolution, redeem.** Winning shares are worthless until you call `ctf redeem`.

```bash
polymarket data positions "$PROXY" -o json | \
  python3 -c 'import sys,json
ps=json.load(sys.stdin)
seen=set()
for p in ps:
    if not p.get("redeemable"): continue
    c=p["condition_id"]
    if c in seen: continue
    seen.add(c)
    print(f"polymarket ctf redeem --condition {c}")' | sh
```

(Read the commands first, run the script after eyeballing.)

## The proxy-wallet signing model

Polymarket uses an EOA + Gnosis Safe pattern:

- The **EOA** owns the key in `~/.config/polymarket/config.json`. It signs every action.
- The **Safe** is a deployed smart contract on Polygon that holds pUSD, conditional tokens, and positions. Each user action executes as a Safe transaction.
- `signature_type: proxy` is the standard. The CLI signs EIP-712 typed data; the Safe validates the signature; the Safe calls the relevant exchange contract.
- **Gas** is paid by the EOA in POL (Polygon native token). The proxy has no gas of its own. Keep a small POL balance in the EOA or orders will fail.

Implication: every order is at least 2 transactions (approve + trade for first time, then 1 per trade). For high-frequency strategies, batch with `post-orders` to reduce overhead.

## Approvals: the six contracts

| Contract | Purpose | Required for |
|---|---|---|
| CTF Exchange | Trading on standard markets | `clob create-order` (non-neg-risk) |
| Neg Risk Exchange | Multi-outcome (election-style) | `clob create-order` (neg-risk) |
| Neg Risk Adapter | Wraps neg-risk | Neg-risk trading |
| Conditional Tokens | ERC1155 outcome tokens | `ctf split / merge` |
| CTF Collateral Adapter | Collateral movement | `ctf redeem` (non-neg-risk) |
| Neg Risk CTF Collateral Adapter | Collateral movement | `ctf redeem-neg-risk` |

`polymarket approve set` issues only the ones that are missing. Re-run it any time you add a new contract role.

## Order types

| Type | Meaning |
|---|---|
| `GTC` (Good Til Cancel) | Default. Sits on the book until filled or cancelled. |
| `GTD` (Good Til Date) | Same as GTC but with an expiry. |
| `FOK` (Fill Or Kill) | All-or-nothing, must fill completely immediately. |
| `FAK` (Fill And Kill) | Fill as much as possible, kill the rest. |

Limit orders use `--price` (decimal 0–1) and `--size` (shares). Market orders use `--amount` (pUSD for buy, shares for sell).

## `ctf` vs `clob` — when to use which

- **`clob create-order / market-order`** — when you want the CLOB's price discovery and liquidity. This is the normal way to trade.
- **`ctf split`** — split pUSD into YES+NO without going through the order book. Useful for providing liquidity or setting up a "long both sides" hedge.
- **`ctf merge`** — burn YES+NO back into pUSD. Use when `data positions` shows `mergeable: true` and you want to unwind before resolution.
- **`ctf redeem`** — after the market resolves and you hold winning shares, this converts shares → pUSD at $1.00 each. One call per condition.

## What `redeemable: true` actually means

`data positions` returns `redeemable: true` for any open position whose market has resolved and where the user holds the winning side. The position shows:

- `current_value: 0`
- `cur_price: 0`
- `size: N` (winning shares, redeemable at $1.00)
- `initial_value: C` (cost basis)

To convert: `polymarket ctf redeem --condition <CID>`. The wallet gains `N` pUSD and loses the shares.

For neg-risk multi-outcome events, use `polymarket ctf redeem-neg-risk --condition <CID> --amounts <n1,n2,...>` instead, with one amount per outcome index set.

## Order sizing & price constraints

- **Minimum order size** is 5 shares (`orderMinSize: "5"`) on most markets. Below that, the order is rejected.
- **Tick size** depends on the market — typically 0.01 or 0.001. Use `clob tick-size <TOKEN>` to check.
- **Fee rate** is set per market. Use `clob fee-rate <TOKEN>` to check the current rate (in basis points).
- **Maker vs taker** — `post-only` makes a limit order maker-only; it won't cross the spread. Default is taker-or-maker.

## Things to NOT do

- Don't reuse the EOA key for anything other than this CLI. If the key is on this machine only and the config is `chmod 600`, that's fine; don't paste it elsewhere.
- Don't drain the EOA's POL balance — orders will fail at signing time with a confusing error.
- Don't expect market orders to fill in illiquid markets. The order will be killed if it can't fill in full (FOK) or partially (FAK).
- Don't run `wallet reset` without backing up the private key. It deletes the config file, not the on-chain positions, but you'll lose the ability to sign.

## Examples

### Buy $10 of YES on a market

```bash
# Find token ID
CID=$(polymarket markets search "btc 100k end of 2026" -o json | python3 -c 'import sys,json
d=json.load(sys.stdin)
print(d[0]["condition_id"])')

TOKEN=$(polymarket clob market "$CID" -o json | python3 -c 'import sys,json
d=json.load(sys.stdin)
print(d["tokens"][0]["token_id"])')

# Buy 20 shares at 0.50
polymarket clob create-order --token "$TOKEN" --side buy --price 0.50 --size 20
```

### Sell a position to close

```bash
polymarket clob create-order --token "$TOKEN" --side sell --price 0.55 --size 20
```

### Redeem all winning positions for a wallet

```bash
ADDR=$(polymarket wallet show -o json | python3 -c 'import sys,json;print(json.load(sys.stdin)["proxy_wallet"])')
polymarket data positions "$ADDR" -o json | python3 <<'PY'
import sys, json, subprocess
ps = json.load(sys.stdin)
seen = set()
for p in ps:
    if not p.get("redeemable"): continue
    c = p["condition_id"]
    if c in seen: continue
    seen.add(c)
    print(f"redeeming {c}: {p['title']} ({float(p['size']):.2f} shares)", file=sys.stderr)
    r = subprocess.run(["polymarket","ctf","redeem","--condition",c], capture_output=True, text=True)
    print(r.stdout, r.stderr)
PY
```
