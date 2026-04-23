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
- page range per request <= 20 pages
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

### Signed Upload 403 Debugging

The `file_url` is an Aliyun OSS signed URL. The signature can include expected request headers. If the upload fails with HTTP 403 and an OSS `SignatureDoesNotMatch` XML body, inspect the actual upload request before retrying the whole parse flow.

A common Python pitfall is using `urllib.request.Request(file_url, data=file_obj, method="PUT")`, which can add:

```text
Content-Type: application/x-www-form-urlencoded
```

That header changes the OSS string-to-sign and can invalidate the signed URL. Use a lower-level request that sends only the required `Content-Length` header, unless MinerU returns a signed URL that explicitly requires more headers.

Minimal Python upload shape:

```python
import http.client
from urllib.parse import urlparse

data = path.read_bytes()
parsed = urlparse(file_url)
request_path = parsed.path
if parsed.query:
    request_path = f"{request_path}?{parsed.query}"

conn = http.client.HTTPSConnection(parsed.netloc, timeout=180)
conn.request("PUT", request_path, body=data, headers={"Content-Length": str(len(data))})
res = conn.getresponse()
body = res.read().decode("utf-8", errors="replace")
if res.status >= 400:
    raise RuntimeError(f"upload failed: {res.status} {body[:1000]}")
```

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

## Long PDFs

For PDFs over 20 pages, keep using the lightweight API by splitting the work into `page_range` chunks of 20 pages or fewer:

```text
1-20
21-40
41-60
```

Upload the same file for each range request, fetch each `markdown_url`, then concatenate the Markdown in page order. Add lightweight page markers such as `<!-- pages 21-40 -->` if the merged output needs traceability.

Use `uv run --with pypdf` to count pages when local Python page counting is needed.

## Practical Implementation Notes

- Poll interval can be 2-5 seconds.
- Stop polling on `done` or `failed`.
- For local file mode, save fetched Markdown beside the source file using the same basename and `.md` extension.
- For batch jobs, there is no server-side batch endpoint. Loop client-side and preserve the source folder layout under the output directory to avoid same-name collisions.
- Save a manifest for batch or range jobs with source, output, task id, state, markdown URL, and error fields.
- Keep responses concise and expose `task_id`, `state`, `markdown_url`, and saved Markdown path.
- If file size exceeds 10 MB, suggest fallback to MinerU standard API endpoints. If only page count exceeds 20, prefer `page_range` chunking first.
