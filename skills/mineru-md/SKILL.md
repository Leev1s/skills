---
name: mineru-md
description: Convert PDF, image, DOCX, PPTX, XLS, and XLSX files to Markdown with MinerU Agent lightweight APIs. Use this skill whenever the user wants document-to-Markdown conversion, local file upload, URL parsing, batch folder conversion, cross-platform curl or PowerShell commands, no-token MinerU parsing, or help debugging lightweight API errors such as signed upload 403s, 10MB file limits, or 20-page PDF limits.
---

# MinerU Markdown Parsing

## Purpose

Use MinerU Agent lightweight parsing to convert supported documents to Markdown with a reliable cross-platform workflow. Prefer the bundled Python helper when Python is available because it handles JSON, polling, minimal signed uploads, manifests, and output paths consistently. Use native command-line tools as fallbacks when Python is unavailable or the user asks for a no-Python path.

MinerU lightweight is:

- no-token, with IP rate limits
- asynchronous: submit, poll by `task_id`, then download `markdown_url`
- Markdown-only output
- single-file per request

## Scope and Limits

Use this skill when each request fits the lightweight API:

- max file size: 10 MB
- max PDF page range per request: 20 pages
- supported types: `pdf`, `png`, `jpg`, `jpeg`, `jp2`, `webp`, `gif`, `bmp`, `docx`, `pptx`, `xls`, `xlsx`
- one file per request

For larger work:

- If a PDF is over 20 pages but still <= 10 MB, split it with `page_range` chunks such as `1-20`, `21-40`, `41-42`, then merge Markdown in order.
- If a file exceeds 10 MB, or the user needs one server-side job for a long document, explain that they should use MinerU Precision/standard API instead.
- MinerU lightweight has no server-side batch endpoint. For folders, loop client-side, preserve source folder layout under the output directory, and write a manifest.

## Tool Selection

Choose the narrowest available toolchain:

1. `uv run scripts/mineru_agent_parse.py` when Python is available. It uses only the Python standard library for the core API flow.
2. `curl` for macOS/Linux/Git Bash when Python is unavailable or the user specifically wants shell commands.
3. PowerShell `Invoke-RestMethod` and `Invoke-WebRequest` for native Windows no-Python workflows.
4. `jq` only when it is already available for JSON field extraction in shell workflows.
5. Manual JSON field copy when only `curl` is available and the user wants a dependency-free path.
6. `wget` only for downloading the final `markdown_url`; do not use it as the primary upload client because signed `PUT` support and header control vary by platform.

When using Python in this repository or environment, run it through `uv run`; do not call `python` or `python3` directly.

## Primary Python Workflow

Use the bundled helper for one-file conversions:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode file \
  --language en \
  --output /path/to/report.md \
  /path/to/report.pdf
```

URL mode:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode url \
  --language en \
  --output report.md \
  'https://example.com/report.pdf'
```

For a known long PDF range:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode file \
  --page-range 21-40 \
  --output report.pages-21-40.md \
  /path/to/report.pdf
```

The helper writes Markdown and a `.mineru.json` manifest by default. Use `--manifest <path>` to choose another manifest path. For folders or multi-range PDFs, call the helper in a loop and concatenate outputs in source/range order.

## API Endpoints

Base URL: `https://mineru.net/api/v1/agent`

- URL mode submit: `POST /parse/url`
- File mode submit: `POST /parse/file`
- Result polling: `GET /parse/{task_id}`

Do not send `Authorization` headers for the lightweight API.

## Workflow

### 1. Pick URL or File Mode

- Use URL mode when the user gives a reachable remote file URL.
- Use file mode when the user gives a local file path or asks to upload a local file.

### 2. Submit the Task

For URL mode:

- `POST /parse/url` with `url` and optional parsing fields
- read `data.task_id`

For file mode:

- `POST /parse/file` with `file_name` and optional parsing fields
- read `data.task_id` and `data.file_url`
- upload bytes to `file_url` with HTTP `PUT`

The Python helper uploads signed URLs with a minimal `http.client` PUT and only `Content-Length`. In no-Python shell workflows, use `curl -T <file> <file_url>` as the first upload attempt because it maps directly to file upload by `PUT` and avoids the common `application/x-www-form-urlencoded` trap from form-style clients. If a signed upload fails with Aliyun OSS `SignatureDoesNotMatch`, debug the upload request before resubmitting the MinerU task.

### 3. Poll Until Terminal State

Poll `GET /parse/{task_id}` every 2-5 seconds until:

- `done`: fetch `data.markdown_url`
- `failed`: report `data.err_code` and `data.err_msg`

Non-terminal states are `waiting-file`, `uploading`, `pending`, and `running`.

### 4. Save Markdown

Fetch the Markdown from `markdown_url` and save UTF-8 text.

- Local file mode: save next to the source file with the same basename and `.md`.
- URL mode: save to the requested output path. If no output path is given, return `markdown_url` and ask where to save it.
- Batch/folder mode: preserve folder layout under the requested output directory to avoid same-name collisions.

For batch jobs, range jobs, tests, and automation, save a manifest with source path, output path, task id, state, markdown URL, and errors. Also keep raw submit, upload, and poll responses when failure debugging matters.

## Cross-Platform Command Recipes

Read [references/agent-lightweight-api.md](references/agent-lightweight-api.md) when you need copyable command templates. Use these defaults:

- Python available on any OS: bundled helper via `uv run`
- macOS/Linux/Git Bash without Python: `curl`, optionally `jq`
- Windows without Python: PowerShell cmdlets first, or `curl.exe` if the user prefers curl
- final Markdown download: `curl -L -o output.md <markdown_url>` or `wget -O output.md <markdown_url>`

If only `curl` is available and no JSON parser exists, keep the workflow semi-manual: save responses to files, show the user exactly which fields to copy (`data.task_id`, `data.file_url`, `data.markdown_url`), then continue with those values.

## Long PDF Handling

When a PDF fails with `err_code: -30003`, or when the user knows it has more than 20 pages:

1. Prefer known page count from the user, document metadata, or existing tools such as `pdfinfo`/`qpdf` if already installed.
2. If a reliable count is needed and Python is acceptable, use `uv run --with pypdf` to count pages.
3. Submit repeated requests with `page_range` values of 20 pages or fewer.
4. Upload the same local file for each range request in file mode.
5. Fetch each range's Markdown.
6. Concatenate chunks in page order and add lightweight markers such as `<!-- pages 21-40 -->` when traceability helps.

Do not abandon lightweight parsing solely because the page count is over 20. Switch to standard API only when file size, accuracy, or one-job requirements justify it.

## Parameters

Common optional fields:

- `language`: default `ch`
- `enable_table`: default `true`
- `is_ocr`: default `false`
- `enable_formula`: default `true`
- `page_range`: one page like `5` or one range like `1-10`

Use `language: en` for English course material or documents. Use `ch` when the document is primarily Chinese or unknown.

## Error Handling

Map lightweight errors directly:

- `-30001`: file exceeds 10 MB lightweight limit
- `-30002`: unsupported file type
- `-30003`: page count exceeds lightweight limit for the submitted request
- `-30004`: invalid request parameters

For HTTP 429, explain IP rate limiting and retry later with slower submission.

For signed upload HTTP 403:

- treat the upload as the failure point
- preserve the signed URL exactly
- remove accidental `Content-Type` or form upload behavior
- retry the upload with `curl -T` or a minimal PowerShell/Python fallback before creating a new MinerU task

## Response Format

Use this concise result shape:

```text
Mode: <url|file|batch>
Task ID: <task_id or N/A>
State: <state>
Markdown URL: <markdown_url or N/A>
Saved Markdown: <local .md path or N/A>
Notes: <limit/error/fallback note if any>
```

If fetched Markdown contains mojibake or broken bullets, report that the issue is present in the MinerU output instead of silently rewriting content.

## References

- [references/agent-lightweight-api.md](references/agent-lightweight-api.md)
