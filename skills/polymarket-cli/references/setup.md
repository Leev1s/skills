# Setup

## Install

The `polymarket` binary on this machine is at `/Users/lev1s/.cargo/bin/polymarket` (also on `PATH`). It was installed via `cargo`:

```bash
cargo install polymarket
```

Requires a Rust toolchain. If you don't have one:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install polymarket
```

Verify:

```bash
polymarket --version
polymarket status
polymarket clob ok
polymarket clob geoblock
```

## First-time wallet setup

The interactive flow is `polymarket setup`, but the equivalent manual steps are:

```bash
# 1. Create or import the EOA key
polymarket wallet create
# or
polymarket wallet import 0xYOUR_KEY

# 2. Show the proxy Safe that gets deployed
polymarket wallet show

# 3. Set approvals (sends txs)
polymarket approve set

# 4. Verify
polymarket approve check "$(polymarket wallet show -o json | python3 -c 'import sys,json;print(json.load(sys.stdin)[\"proxy_wallet\"])')"
```

If the proxy is already deployed, `setup` skips re-deployment.

## Funding the wallet

The EOA needs a small POL balance to pay gas. The proxy needs pUSD to trade. Bridge from any supported chain:

```bash
polymarket bridge supported-assets
PROXY=$(polymarket wallet show -o json | python3 -c 'import sys,json;print(json.load(sys.stdin)["proxy_wallet"])')
polymarket bridge deposit "$PROXY"
```

Send USDC (or the supported asset) to the deposit address returned. The bridge routes it to your proxy on Polygon as pUSD.

## Geoblock

Some regions are blocked by the CLOB. The CLI prints the status with `polymarket clob geoblock`. If blocked, you cannot place orders from that network — but read endpoints still work.

## Uninstallation

```bash
cargo uninstall polymarket
# optionally wipe the local config
polymarket wallet reset --force
```

Note: `wallet reset` only deletes the local key/config — your on-chain positions, proxy Safe, and approvals are still on Polygon. Keep your seed phrase to recover.
