# MinerU Agent Lightweight API Reference

Source:

- `https://mineru.net/apiManage/docs`
- `https://mineru.net/doc/docs/` (Agent lightweight section)

## What this API is for

Agent lightweight parsing is designed for quick AI-agent parsing into Markdown without token login.

Key characteristics:

- no token auth
- IP rate limiting
- async task flow
- Markdown-only output

## Limits

- file size <= 10 MB
- page count <= 20
- supported file types:
  - `pdf`
  - image: `png/jpg/jpeg/jp2/webp/gif/bmp`
  - `docx`
  - `pptx`
  - `xls`, `xlsx`

## Endpoints

Base: `https://mineru.net/api/v1/agent`

1) URL submit:

- `POST /parse/url`

2) File submit (signed upload):

- `POST /parse/file`
- then `PUT` bytes to returned `file_url`

3) Poll result:

- `GET /parse/{task_id}`

## URL Submit Request

Endpoint:

```text
POST https://mineru.net/api/v1/agent/parse/url
```

JSON body fields:

- required:
  - `url`
- optional:
  - `file_name`
  - `language` (default `ch`)
  - `enable_table` (default `true`)
  - `is_ocr` (default `false`)
  - `enable_formula` (default `true`)
  - `page_range` (`1-10` or single page like `5`)

Notes:

- no `Authorization` required
- use `Content-Type: application/json`

Success response fields:

- `code` (`0` means success)
- `msg`
- `trace_id`
- `data.task_id`

## File Submit Request (Signed Upload)

Endpoint:

```text
POST https://mineru.net/api/v1/agent/parse/file
```

JSON body fields:

- required:
  - `file_name`
- optional:
  - `language`
  - `enable_table`
  - `is_ocr`
  - `enable_formula`
  - `page_range`

Success response fields:

- `data.task_id`
- `data.file_url` (signed URL for direct `PUT` upload)

Flow:

1. call `POST /parse/file`
2. `PUT` local file to `file_url`
3. keep the signed `PUT` request minimal; avoid adding custom headers unless the signed URL explicitly requires them
4. poll `GET /parse/{task_id}`

## Polling Response

Endpoint:

```text
GET https://mineru.net/api/v1/agent/parse/{task_id}
```

State values:

- `waiting-file`
- `uploading`
- `pending`
- `running`
- `done`
- `failed`

Fields on done:

- `data.markdown_url`

Fields on failed:

- `data.err_code`
- `data.err_msg`

## Agent-Specific Error Codes

- `-30001`: file exceeds 10MB lightweight limit
- `-30002`: unsupported file type for lightweight API
- `-30003`: page count exceeds lightweight limit
- `-30004`: request parameter error

## Practical Implementation Notes

- Poll interval can be 2-5 seconds.
- Stop polling on `done` or `failed`.
- For local file mode, save fetched Markdown beside the source file using the same basename and `.md` extension.
- Keep responses concise and expose `task_id`, `state`, `markdown_url`, and saved Markdown path.
- If limits are exceeded, suggest fallback to MinerU standard API endpoints.
