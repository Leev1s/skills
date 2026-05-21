---
name: see
description: Use the S.EE `see` CLI for short URLs, text snippets, file uploads, image hosting, domains, tags, JSON output, and delete hashes. Use when the user asks to run, explain, document, or troubleshoot the installed `see` command-line tool.
---

# S.EE CLI

Use `see` to create short links, share text, and upload files. Trust the installed CLI help first; local `see-cli 1.2.0` uses `see shorturl ...`.

## Quick Checks

```bash
command -v see
see version
if [[ -n "$SEE_API_KEY" ]]; then echo "SEE_API_KEY=set"; else echo "SEE_API_KEY=missing"; fi
```

Check available domains:

```bash
see domains --json
see text domains --json
see file domains --json
see tags --json
```

## Common Commands

```bash
see shorturl create https://example.com --json
see shorturl update my-slug --target-url https://example.org --json
see shorturl delete my-slug --json

see text create --file ./notes.md --title "Notes" --json
printf '%s\n' 'hello' | see text create --title "Greeting" --json
see text delete my-slug --json

see file upload ./image.png --json
see file upload --file - --name image.png --json
see file history --json
see file download-url <file-id> --json
see file delete <delete-hash-or-key> --json
```

Use `--json` by default for agent/script work. Do not print API keys. Confirm before deleting unless the user gave the exact slug/hash/key.

For full flags, read [references/cli-reference.md](references/cli-reference.md).
