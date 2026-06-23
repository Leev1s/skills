# Shell, Scripting & Integration

## Interactive shell

```bash
polymarket shell
```

Drops you into a REPL with all top-level commands available — no need to repeat `polymarket`. Global flags (`-o json`, `--private-key`, `--signature-type`) set in the shell stick for the session. Type `exit` or `Ctrl-D` to leave.

The shell is most useful for exploratory work over many small queries. For anything scriptable, prefer `polymarket <cmd> -o json | <pipeline>` so the data is reproducible.

## JSON output

Every command supports `-o json` (or `-o table`, default `table`). The shape varies by endpoint:

- Most list endpoints return a **JSON array**.
- `data value` returns a single object: `{"user": "...", "value": "..."}`.
- `clob book` returns a single object with `bids` and `asks` arrays.
- `clob markets` and `events list` may return paginated wrappers — check the actual response.

Always inspect the first response from a new endpoint before writing a parser:

```bash
polymarket data activity "$ADDR" --limit 1 -o json | python3 -m json.tool | head -30
```

## Pagination

Most `list` endpoints take `--limit` and `--offset` rather than cursors. Some newer ones (e.g. `clob trades`) use `--cursor`.

Default limits are 25. Increase for batch operations:

```bash
polymarket data trades "$ADDR" --limit 500 -o json
```

For analytics scripts, paginate with `offset += limit` until you get fewer rows than the page size.

## Exit codes

The CLI returns non-zero on most errors. Tested cases:

- Invalid market ID: non-zero exit.
- Invalid wallet address: non-zero exit, error message on stderr.
- `clob book` for a closed market: non-zero exit, 404 error in JSON.

Check with `if polymarket ... ; then ...; fi` in bash.

## Environment variables

Confirmed:

- `POLYMARKET_PRIVATE_KEY` (or `PRIVATE_KEY`?) — not officially documented; the CLI precedence is `--private-key` flag > env var > config file. Use the config file.

Use `polymarket wallet show` to verify which source is active. Output includes `Key source: config file | env var | --private-key flag`.

## Config file

`~/.config/polymarket/config.json` — chmod-restricted by the CLI. Shape:

```json
{
  "private_key": "0xacec...fd67",
  "chain_id": 137,
  "signature_type": "proxy"
}
```

Do not edit by hand. Use `wallet create / import / reset`.

## API key management (programmatic)

The CLOB supports API keys for low-overhead read auth (avoiding full L2 signing on every read):

```bash
polymarket clob create-api-key    # creates or derives the key
polymarket clob api-keys          # lists
polymarket clob delete-api-key    # deletes current
```

The CLI handles key creation transparently when needed for read endpoints.

## Reusable recipes

### Full wallet snapshot

`snapshot.sh <ADDRESS>` — runs every read endpoint and writes JSON files to `./polymarket-snapshot-<addr>-<ts>/`.

### Find unclaimed winnings

`find-unclaimed.sh <ADDRESS>` — emits one `polymarket ctf redeem` command per unique redeemable condition, prefixed with the market title and share count.

### Watch a market

`market-watch.sh <CONDITION_ID> [INTERVAL_SEC]` — polls `clob midpoint` and prints a streaming table.

## Piping patterns

### Top markets by 24h volume

```bash
polymarket markets list --order volume_num --limit 20 -o json | \
  python3 -c 'import sys,json
for m in json.load(sys.stdin):
    print(f"${float(m[\"volume24hr\"]):>10.0f}  ${float(m[\"liquidity\"]):>10.0f}  {m[\"question\"][:60]}")'
```

### Find a token ID by market slug

```bash
SLUG="btc-updown-5m-1773759000"
polymarket markets get "$SLUG" -o json | python3 -c 'import sys,json
m = json.load(sys.stdin)
import json as j
toks = j.loads(m["clobTokenIds"])
print("up/down token IDs:", toks)'
```

### Cross-reference profile + positions

```bash
ADDR=0x21B1E7fD66aDE3a697cd06c293568Ef53473DDc2
{ polymarket profiles get "$ADDR" -o json | python3 -c 'import sys,json; p=json.load(sys.stdin); print(f"# {p[\"pseudonym\"]} ({p[\"name\"]})")'
  polymarket data positions "$ADDR" -o json | python3 -c 'import sys,json
ps = json.load(sys.stdin)
for p in ps:
    if p.get("redeemable"):
        print(f"  UNCLAIMED  {float(p[\"size\"]):>8.2f} shares  {p[\"title\"][:55]}")'
}
```

## Rate limits & errors

The Polymarket public APIs have generous but not unlimited rate limits. If you see HTTP 429, back off. The CLI does not retry by default — wrap your scripts with a small delay loop.

For long-running pipelines:

```bash
while ! polymarket markets list --limit 1 -o json > /dev/null 2>&1; do
  sleep 5
done
```

## Background usage

`polymarket shell` is foreground. For long-running traders, use `nohup` + cron, or a tmux session:

```bash
nohup polymarket markets list --limit 500 -o json > snapshot.json 2>&1 &
```

The CLI writes errors to stderr; logs to `snapshot.json` will be clean JSON.

## Versioning

```bash
polymarket --version
polymarket upgrade
```

After upgrade, re-run `--help` on any commands you depend on — flags can move between minor versions.
