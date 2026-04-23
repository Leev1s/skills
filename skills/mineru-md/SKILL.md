---
name: mineru-md
description: Parse documents into Markdown using MinerU Agent lightweight APIs (no token required). Use this skill whenever the user asks to convert PDF, image, DOCX, PPTX, XLS, or XLSX into Markdown quickly, especially in AI agent workflows, and when files are within lightweight limits (10MB, 20 pages).
---

# MinerU Markdown Parsing

## Overview

Use this skill to run MinerU Agent lightweight parsing and save Markdown next to the source file.

This API is:

- token-free (IP rate limited)
- asynchronous (submit task, then poll by `task_id`)
- Markdown-only output (`markdown_url`)

## Limits and Scope

Apply this skill when the input fits lightweight limits:

- max file size: 10 MB
- max page count: 20 pages
- supported types: PDF, images (`png/jpg/jpeg/jp2/webp/gif/bmp`), `docx`, `pptx`, `xls`, `xlsx`
- one file per request (no batch mode)

If the task exceeds these limits, state that the user should switch to MinerU standard API.

## API Endpoints

Base URL: `https://mineru.net/api/v1/agent`

- URL mode submit: `POST /parse/url`
- File mode submit: `POST /parse/file`
- Result polling: `GET /parse/{task_id}`

Do not require `Authorization` headers for this lightweight API.

## Execution Workflow

### 1. Choose mode

- Use URL mode when the user provides a reachable remote URL.
- Use file mode when the user provides a local file path or asks to upload a file.

### 2. Submit task

For URL mode:

- call `POST /parse/url` with `url` and optional parsing fields
- read `data.task_id`

For file mode:

- call `POST /parse/file` with `file_name` and optional parsing fields
- read `data.task_id` and `data.file_url`
- upload file bytes to `file_url` using HTTP `PUT`
- keep the signed upload request minimal; do not add custom headers unless the upload URL explicitly requires them, because extra headers can break signature validation

### 3. Poll status

Poll `GET /parse/{task_id}` until terminal state:

- `done`: use `data.markdown_url`
- `failed`: surface `data.err_code` and `data.err_msg`

Non-terminal states:

- `waiting-file`
- `uploading`
- `pending`
- `running`

### 4. Save and return result

When done, return:

- `task_id`
- final `state`
- `markdown_url`

Fetch the markdown from `markdown_url`.

For local file mode, save the fetched Markdown in the same directory as the source file. Rename the output to match the source file basename with a `.md` extension:

- source: `/path/to/report.pdf`
- output: `/path/to/report.md`

For URL mode, save to the requested output path when the user provides one. If no output path is provided, return the `markdown_url` and ask where to save the Markdown.

For tests or automation runs, save the raw submit response, upload status, poll responses, and fetched Markdown under the requested output directory. This makes failures easy to inspect without rerunning the API.

## Parameter Guidance

Common optional parameters (mainly for PDF):

- `language` (default `ch`)
- `enable_table` (default `true`)
- `is_ocr` (default `false`)
- `enable_formula` (default `true`)
- `page_range` (single page like `5` or range like `1-10`)

Use defaults unless the user specifies otherwise.

## Error Handling

Map known lightweight errors directly:

- `-30001`: file too large for lightweight API (10MB)
- `-30002`: unsupported file type for lightweight API
- `-30003`: page count exceeds lightweight API limit
- `-30004`: invalid request parameters

For these errors, explain the exact cause and propose the minimal next step.

## Output Format

Use this concise response structure:

```text
Mode: <url|file>
Task ID: <task_id>
State: <state>
Markdown URL: <markdown_url or N/A>
Saved Markdown: <local .md path or N/A>
Notes: <limit/error/fallback note if any>
```

When saving fetched Markdown, write UTF-8 text. If bullet characters or non-ASCII text appear as mojibake, report that the issue is present in the fetched Markdown output instead of silently rewriting the content.

## References

For exact fields and examples, read:

- [references/agent-lightweight-api.md](references/agent-lightweight-api.md)
