# S.EE CLI Reference

Local version checked: `see-cli 1.2.0 (2026-02-26T16:30:05Z)`.

## Install and Auth

```bash
brew tap sdotee/homebrew-tap
brew install see
go install github.com/sdotee/cli@latest
```

Linux packages are available as `.deb`, `.rpm`, and Arch packages (`see-cli`, `see-cli-bin`).

Auth:

```bash
export SEE_API_KEY="your-api-key"
see --api-key "your-api-key" <command>
```

Global flags: `--api-key`, `--base-url`, `--timeout`, `--json`, `--help`, `--version`.

## Commands

### Domains and Tags

```bash
see domains --json
see text domains --json
see file domains --json
see tags --json
```

### Short URLs

```bash
see shorturl create <target-url> [flags]
see shorturl update <slug> [flags]
see shorturl delete <slug> [flags]
```

Create flags: `--domain`, `--slug`, `--title`, `--password`, `--expire-at`, `--expiration-redirect-url`, `--tag-ids`.

Update flags: `--domain`, `--target-url`, `--title`.

Delete flag: `--domain`.

### Text

```bash
see text create [flags]
see text update <slug> [flags]
see text delete <slug> [flags]
see text domains --json
```

Create flags: `--file`, `--domain`, `--slug`, `--title`, `--type`, `--password`, `--expire-at`, `--tag-ids`.

Update flags: `--domain`, `--file`, `--title`.

Delete flag: `--domain`.

### Files

```bash
see file upload [file...] [flags]
see file history --page 1 --json
see file download-url <file-id> --json
see file delete <key...> --json
see file domains --json
```

Upload flags: `--file`/`-f`, `--name`/`-n`, `--is-private`.

Useful upload JSON fields: `url`, `page`, `file_id`, `hash`, `delete`, `filename`, `size`.
