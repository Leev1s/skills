"""Parse one document to Markdown with MinerU Agent lightweight API."""

from __future__ import annotations

import argparse
import http.client
import json
import mimetypes
import pathlib
import sys
import time
import urllib.error
import urllib.request
from typing import Optional
from urllib.parse import urlparse


BASE_URL = "https://mineru.net/api/v1/agent"
TERMINAL_STATES = {"done", "failed"}


def request_json(method: str, url: str, payload: Optional[dict] = None) -> dict:
    data = None
    headers = {}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            return json.loads(res.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from {url}: {body[:1000]}") from exc


def put_file_minimal(file_url: str, path: pathlib.Path) -> int:
    data = path.read_bytes()
    parsed = urlparse(file_url)
    request_path = parsed.path + (f"?{parsed.query}" if parsed.query else "")

    conn = http.client.HTTPSConnection(parsed.netloc, timeout=180)
    conn.request(
        "PUT",
        request_path,
        body=data,
        headers={"Content-Length": str(len(data))},
    )
    res = conn.getresponse()
    body = res.read().decode("utf-8", errors="replace")
    if res.status >= 400:
        raise RuntimeError(f"upload failed: HTTP {res.status}: {body[:1000]}")
    return res.status


def download_text(url: str, output: pathlib.Path) -> None:
    req = urllib.request.Request(url, method="GET")
    with urllib.request.urlopen(req, timeout=180) as res:
        text = res.read().decode("utf-8", errors="replace")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(text, encoding="utf-8")


def build_payload(args: argparse.Namespace, file_name: Optional[str] = None) -> dict:
    payload = {
        "language": args.language,
        "enable_table": args.enable_table,
        "is_ocr": args.is_ocr,
        "enable_formula": args.enable_formula,
    }
    if args.page_range:
        payload["page_range"] = args.page_range
    if args.mode == "url":
        payload["url"] = args.source
        if file_name:
            payload["file_name"] = file_name
    else:
        payload["file_name"] = file_name
    return payload


def default_output(args: argparse.Namespace) -> pathlib.Path:
    if args.output:
        return pathlib.Path(args.output)
    if args.mode == "file":
        return pathlib.Path(args.source).with_suffix(".md")
    name = pathlib.Path(urlparse(args.source).path).name or "mineru-output"
    stem = pathlib.Path(name).stem or "mineru-output"
    return pathlib.Path(f"{stem}.md")


def poll(task_id: str, interval: float, timeout: float) -> dict:
    deadline = time.monotonic() + timeout
    last = {}
    while time.monotonic() < deadline:
        last = request_json("GET", f"{BASE_URL}/parse/{task_id}")
        state = last.get("data", {}).get("state")
        print(f"state={state}", file=sys.stderr)
        if state in TERMINAL_STATES:
            return last
        time.sleep(interval)
    raise TimeoutError(f"timed out waiting for task {task_id}; last response: {last}")


def write_manifest(path: Optional[pathlib.Path], manifest: dict) -> None:
    if not path:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", help="Remote URL or local file path")
    parser.add_argument("--mode", choices=["url", "file"], required=True)
    parser.add_argument("--output", help="Markdown output path")
    parser.add_argument("--manifest", help="Optional JSON manifest path")
    parser.add_argument("--language", default="ch")
    parser.add_argument("--page-range")
    table_group = parser.add_mutually_exclusive_group()
    table_group.add_argument("--enable-table", dest="enable_table", action="store_true", default=True)
    table_group.add_argument("--no-enable-table", dest="enable_table", action="store_false")
    ocr_group = parser.add_mutually_exclusive_group()
    ocr_group.add_argument("--is-ocr", dest="is_ocr", action="store_true", default=False)
    ocr_group.add_argument("--no-is-ocr", dest="is_ocr", action="store_false")
    formula_group = parser.add_mutually_exclusive_group()
    formula_group.add_argument("--enable-formula", dest="enable_formula", action="store_true", default=True)
    formula_group.add_argument("--no-enable-formula", dest="enable_formula", action="store_false")
    parser.add_argument("--poll-interval", type=float, default=3)
    parser.add_argument("--timeout", type=float, default=300)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    output = default_output(args)
    manifest_path = pathlib.Path(args.manifest) if args.manifest else output.with_suffix(".mineru.json")

    if args.mode == "url":
        submit = request_json("POST", f"{BASE_URL}/parse/url", build_payload(args))
        upload_status = None
    else:
        source_path = pathlib.Path(args.source)
        if not source_path.exists():
            raise FileNotFoundError(source_path)
        file_name = source_path.name
        if not pathlib.Path(file_name).suffix and not mimetypes.guess_type(file_name)[0]:
            raise ValueError("file_name should include a supported extension")
        submit = request_json("POST", f"{BASE_URL}/parse/file", build_payload(args, file_name))
        file_url = submit.get("data", {}).get("file_url")
        if not file_url:
            raise RuntimeError(f"missing file_url in submit response: {submit}")
        upload_status = put_file_minimal(file_url, source_path)

    task_id = submit.get("data", {}).get("task_id")
    if not task_id:
        raise RuntimeError(f"missing task_id in submit response: {submit}")

    result = poll(task_id, args.poll_interval, args.timeout)
    data = result.get("data", {})
    state = data.get("state")
    markdown_url = data.get("markdown_url")

    manifest = {
        "mode": args.mode,
        "source": args.source,
        "output": str(output),
        "task_id": task_id,
        "state": state,
        "markdown_url": markdown_url,
        "submit_response": submit,
        "final_response": result,
        "upload_status": upload_status,
    }
    write_manifest(manifest_path, manifest)

    if state == "failed":
        err_code = data.get("err_code")
        err_msg = data.get("err_msg")
        raise RuntimeError(f"MinerU failed: {err_code} {err_msg}")
    if state != "done" or not markdown_url:
        raise RuntimeError(f"unexpected final response: {result}")

    download_text(markdown_url, output)
    print(json.dumps({k: manifest[k] for k in ("mode", "task_id", "state", "markdown_url", "output")}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
