# MinerU Agent Lightweight API Reference

Sources:

- `https://mineru.net/doc/docs/index_en/`
- `https://mineru.net/apiManage/docs`

The official docs describe Agent Lightweight Extract API as a no-login, no-token, IP-rate-limited API for AI-agent document extraction. It outputs Markdown by CDN URL and supports URL submission or signed local-file upload.

## Limits

- File size: <= 10 MB
- PDF page count per request: <= 20 pages
- Batch support: none server-side; loop client-side
- Output: Markdown only
- File types: `pdf`, `png`, `jpg`, `jpeg`, `jp2`, `webp`, `gif`, `bmp`, `docx`, `pptx`, `xls`, `xlsx`

## Endpoints

Base URL:

```text
https://mineru.net/api/v1/agent
```

Endpoints:

- `POST /parse/url`
- `POST /parse/file`
- `GET /parse/{task_id}`

No `Authorization` header is required for these lightweight endpoints.

## Primary Python Helper

When Python is available, prefer the bundled helper because it keeps the whole flow structured and repeatable across macOS, Linux, and Windows. It uses only the Python standard library for submit, minimal signed upload, polling, Markdown download, and manifest writing.

Local file:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode file \
  --language en \
  --output document.md \
  document.pdf
```

Remote URL:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode url \
  --language en \
  --output document.md \
  'https://example.com/document.pdf'
```

One PDF range:

```bash
uv run skills/mineru-md/scripts/mineru_agent_parse.py \
  --mode file \
  --page-range 21-40 \
  --output document.pages-21-40.md \
  document.pdf
```

The helper writes a JSON manifest next to the Markdown by default. Use `--manifest run.json` to choose a path.

Use the command-only sections below when Python is unavailable, the user explicitly wants `curl`, or you need to explain the raw API.

## URL Mode with curl

Submit a public URL:

```bash
curl -sS --location --request POST 'https://mineru.net/api/v1/agent/parse/url' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "url": "https://example.com/document.pdf",
    "language": "en",
    "page_range": "1-10",
    "enable_table": true,
    "is_ocr": false,
    "enable_formula": true
  }' \
  -o submit.json
```

Extract `task_id` when `jq` is available:

```bash
task_id="$(jq -r '.data.task_id' submit.json)"
```

If `jq` is not available, open `submit.json` and copy `data.task_id` manually. Avoid brittle JSON parsing for automation unless the user accepts the tradeoff.

## File Mode with curl

Step 1: request a signed upload URL.

```bash
curl -sS --location --request POST 'https://mineru.net/api/v1/agent/parse/file' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "file_name": "document.pdf",
    "language": "en",
    "page_range": "1-10",
    "enable_table": true,
    "is_ocr": false,
    "enable_formula": true
  }' \
  -o submit.json
```

Step 2: extract fields when `jq` is available.

```bash
task_id="$(jq -r '.data.task_id' submit.json)"
file_url="$(jq -r '.data.file_url' submit.json)"
```

Step 3: upload bytes to the signed URL.

```bash
curl -sS --fail --request PUT -T 'document.pdf' "$file_url"
```

`curl -T` is the preferred first attempt for signed uploads because it sends the file as a PUT upload rather than form data. The official MinerU docs also show a `curl --request PUT --data-binary '@document.pdf'` form; if using that form and an OSS signature error appears, retry with `curl -T` and clear accidental content headers before resubmitting the parse task.

## Polling with curl

Query status:

```bash
curl -sS --location --request GET "https://mineru.net/api/v1/agent/parse/${task_id}" \
  -o poll.json
```

Extract status fields when `jq` is available:

```bash
state="$(jq -r '.data.state' poll.json)"
markdown_url="$(jq -r '.data.markdown_url // empty' poll.json)"
err_code="$(jq -r '.data.err_code // empty' poll.json)"
err_msg="$(jq -r '.data.err_msg // empty' poll.json)"
```

Simple POSIX polling loop with `curl` and `jq`:

```bash
for i in $(seq 1 100); do
  curl -sS "https://mineru.net/api/v1/agent/parse/${task_id}" -o poll.json
  state="$(jq -r '.data.state' poll.json)"
  if [ "$state" = "done" ]; then
    markdown_url="$(jq -r '.data.markdown_url' poll.json)"
    curl -sS -L "$markdown_url" -o 'document.md'
    break
  fi
  if [ "$state" = "failed" ]; then
    jq -r '.data | "error \(.err_code): \(.err_msg)"' poll.json
    break
  fi
  sleep 3
done
```

Without `jq`, run the GET command repeatedly and copy `data.markdown_url` when `data.state` becomes `done`.

## Windows PowerShell Workflow

PowerShell has built-in JSON handling, so it is the cleanest native Windows path.

URL mode:

```powershell
$body = @{
  url = "https://example.com/document.pdf"
  language = "en"
  page_range = "1-10"
  enable_table = $true
  is_ocr = $false
  enable_formula = $true
} | ConvertTo-Json

$submit = Invoke-RestMethod `
  -Method Post `
  -Uri "https://mineru.net/api/v1/agent/parse/url" `
  -ContentType "application/json" `
  -Body $body

$taskId = $submit.data.task_id
```

File mode:

```powershell
$filePath = ".\document.pdf"
$body = @{
  file_name = Split-Path $filePath -Leaf
  language = "en"
  page_range = "1-10"
  enable_table = $true
  is_ocr = $false
  enable_formula = $true
} | ConvertTo-Json

$submit = Invoke-RestMethod `
  -Method Post `
  -Uri "https://mineru.net/api/v1/agent/parse/file" `
  -ContentType "application/json" `
  -Body $body

$taskId = $submit.data.task_id
Invoke-WebRequest -Method Put -Uri $submit.data.file_url -InFile $filePath
```

Polling and download:

```powershell
for ($i = 0; $i -lt 100; $i++) {
  $result = Invoke-RestMethod -Method Get -Uri "https://mineru.net/api/v1/agent/parse/$taskId"
  if ($result.data.state -eq "done") {
    Invoke-WebRequest -Uri $result.data.markdown_url -OutFile ".\document.md"
    break
  }
  if ($result.data.state -eq "failed") {
    throw "MinerU failed: $($result.data.err_code) $($result.data.err_msg)"
  }
  Start-Sleep -Seconds 3
}
```

If PowerShell upload returns `SignatureDoesNotMatch`, retry with `curl.exe -T .\document.pdf "<file_url>"` because `curl.exe` can avoid headers added by higher-level web cmdlets.

## Final Markdown Download Alternatives

Use `curl`:

```bash
curl -sS -L "$markdown_url" -o output.md
```

Use `wget` only for this final download step:

```bash
wget -O output.md "$markdown_url"
```

## Python Low-Level Fallback via uv

The bundled helper is the normal Python path. Use this lower-level fallback only when debugging a signed upload outside the helper. In this repository, always run Python through `uv run`.

Minimal signed upload fallback script (`upload_minimal.py`):

```python
import http.client
import pathlib
import sys
from urllib.parse import urlparse

file_url = sys.argv[1]
path = pathlib.Path(sys.argv[2])
data = path.read_bytes()
parsed = urlparse(file_url)
request_path = parsed.path + (f"?{parsed.query}" if parsed.query else "")

conn = http.client.HTTPSConnection(parsed.netloc, timeout=180)
conn.request("PUT", request_path, body=data, headers={"Content-Length": str(len(data))})
res = conn.getresponse()
body = res.read().decode("utf-8", errors="replace")
print(res.status)
if res.status >= 400:
    print(body[:1000])
    raise SystemExit(1)
```

Run it with:

```bash
uv run upload_minimal.py "$file_url" document.pdf
```

Page counting fallback:

```bash
uv run --with pypdf - <<'PY'
import sys
from pypdf import PdfReader

reader = PdfReader(sys.argv[1])
print(len(reader.pages))
PY
```

## Long PDF Strategy

For a 42-page PDF, submit these ranges:

```text
1-20
21-40
41-42
```

For URL mode, submit the same URL with each `page_range`. For file mode, request a new `task_id` and `file_url` for each `page_range`, upload the same file to each signed URL, poll each task, download each Markdown result, then concatenate in order.

Useful merge marker:

```markdown
<!-- pages 21-40 -->
```

## Response Fields

Submit success:

- `code`: `0` means success
- `data.task_id`
- `data.file_url` for file mode only

Poll states:

- `waiting-file`
- `uploading`
- `pending`
- `running`
- `done`
- `failed`

Done:

- `data.markdown_url`

Failed:

- `data.err_code`
- `data.err_msg`

## Error Codes

- `-30001`: file exceeds 10 MB lightweight limit
- `-30002`: unsupported file type
- `-30003`: page count exceeds lightweight limit for the submitted request
- `-30004`: request parameter error

HTTP 429 means IP rate limiting; slow down and retry later.

## Signed Upload 403 Checklist

When upload fails with Aliyun OSS `SignatureDoesNotMatch`:

1. Do not repeatedly call `/parse/file`; the submit step already worked.
2. Preserve the `file_url` exactly, including query parameters.
3. Retry upload with `curl -T`:

   ```bash
   curl -v --request PUT -T 'document.pdf' "$file_url"
   ```

4. If another client is used, remove automatic `Content-Type: application/x-www-form-urlencoded`.
5. If the signed URL has expired, request a new file task and upload immediately.
