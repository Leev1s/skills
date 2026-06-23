# Scripting

## Output

All commands accept `-o json` (or `-o table`, default table). Field naming is snake_case. Numbers are strings — cast to float.

- Most lists return a plain JSON array.
- `data value` returns `{"user": "...", "value": "..."}`.
- `clob book` returns `{"bids": [...], "asks": [...], ...}`.
- `clob markets` and some others use paginated wrappers — check the actual response.

Always inspect the first response from a new endpoint before writing a parser:

```bash
polymarket data activity "$ADDR" --limit 1 -o json | python3 -m json.tool | head -30
```

## Pagination

Most `list` endpoints take `--limit` and `--offset`. Some (`clob trades`) use `--cursor`. Default limit 25.

## Exit codes

Non-zero on most errors: invalid market ID, invalid wallet address, `clob book` for a closed market (404). `if polymarket ... ; then ...; fi`.

## Env / config

Config: `~/.config/polymarket/config.json` — `{"private_key": "0x...", "chain_id": 137, "signature_type": "proxy"}`. Don't edit by hand; use `wallet create / import / reset`.

Auth precedence: `--private-key` flag > env > config file. Check active source with `polymarket wallet show` (prints `Key source:`).

## API keys (programmatic reads)

```bash
polymarket clob create-api-key
polymarket clob api-keys
polymarket clob delete-api-key
```

CLI handles key creation transparently for reads.

## Rate limits

Public APIs are generous but not unlimited. On HTTP 429, back off. CLI does not retry — wrap in your own loop with sleep.

## Watch a market

```bash
TOKEN=<token_id>
while true; do
  polymarket clob midpoint "$TOKEN" -o json | python3 -c "import sys,json; print(json.load(sys.stdin))"
  sleep 10
done
```

Or use the bundled `scripts/market-watch.sh <CONDITION_ID>` which resolves the token for you.
