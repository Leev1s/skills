---
name: mcp-guide
description: Use local MCP tools deliberately and choose the right one based on the task. Trigger this skill when the user asks to search the web, verify current information, retrieve official docs, inspect or extract websites, look up GitHub metadata, query Hugging Face resources, or when Codex needs a practical guide for routing among the MCP tools available in the local environment.
---

# Mcp Guide

## Overview

Choose the MCP tool based on the shape of the task, not habit. Prefer the narrowest tool that can answer the request with the least noise and the strongest source quality.

## Local MCP Inventory

This environment currently exposes these MCP namespaces:

- `mcp__brave__`
- `mcp__tavily__`
- `mcp__context7__`
- `mcp__codex_apps__github`
- `mcp__codex_apps__hugging_face`

## Tool Routing

Use `mcp__context7__` first for library and framework documentation:

- Use `resolve_library_id`, then `query_docs`.
- Prefer this over web search for SDKs, APIs, framework behavior, migrations, and usage examples.
- Treat Context7 as the primary source for technical documentation because it is narrower and less noisy than web search.

Use `mcp__brave__` for broad live web discovery:

- Use `brave_web_search` for general current information, fact checks, and source discovery.
- Use `brave_news_search` for current events and recent timelines.
- Use `brave_image_search` for visual references.
- Use `brave_video_search` for interviews, talks, demos, and tutorials.
- Use `brave_local_search` only when location search matters and the user has Brave Pro access; otherwise fall back to `brave_web_search`.
- Use `brave_summarizer` only after `brave_web_search` with `summary=true`, and only when account support is available.

Use `mcp__tavily__` when you need the page itself, not just search snippets:

- Use `tavily_search` for current web search when you want domain filters, raw page content, or richer extraction in the response.
- Use `tavily_extract` to pull full page content from known URLs.
- Use `tavily_map` to discover a site's structure before selecting pages.
- Use `tavily_crawl` to traverse a site and collect pages matching instructions.
- Use `tavily_research` for broad multi-source synthesis when the user wants a researched answer rather than manual stepwise browsing.

## Selection Heuristics

- If the user asks for official usage of a library, use Context7.
- If the user asks what is happening now on the web, use Brave or Tavily.
- If the user already has URLs, use Tavily extract instead of search.
- If the user wants to inspect a documentation site's shape, use Tavily map or crawl.
- If the user wants local businesses, use Brave local search only with confirmed Pro access.
- If one search tool returns noisy results, switch to the other rather than forcing the same tool.
- If the user wants GitHub PR or CI metadata, use the GitHub MCP instead of scraping GitHub pages.
- If the user wants Hugging Face Spaces or account identity, use the Hugging Face MCP instead of web search.

## Workflow

1. Classify the request: official docs, live web facts, news, page extraction, site inspection, visual search, video search, or local lookup.
2. Pick the narrowest MCP that matches that class.
3. Query with concrete nouns, product names, versions, dates, and domains where available.
4. For unstable facts, add recency constraints and state exact dates in the answer.
5. Cross-check important claims across multiple sources unless the user asked for a single-source lookup.
6. Return the answer first, then cite the sources with links.

## Querying Guidance

- Keep searches literal and focused.
- Split multi-part questions into multiple searches.
- Use country and locale parameters only when geography matters.
- Use include-domain or exclude-domain filters when the user specifies source preferences.
- Prefer extraction after discovery: search first, then extract the final pages you actually need.

## Output Rules

- Lead with the conclusion.
- Distinguish sourced facts from your inference.
- Cite the exact pages used.
- Do not dump raw search results unless the user asked for them.
- Say when a tool is available but account-limited.
- Say when the available results are sparse, noisy, or conflicting.

## Observed Output Shapes

Expect these response patterns based on local usage:

- `brave_web_search`, `brave_news_search`, and `brave_video_search` usually return a list of JSON-like strings, one result per item, commonly containing `url`, `title`, and `description`. News results also include fields like `age` and `page_age`. Video results commonly include `duration` and `thumbnail_url`.
- `brave_image_search` returns an object-like payload with `items`, `count`, and `might_be_offensive`. Each image item commonly includes `title`, `url`, `page_fetched`, `confidence`, and `properties.url`.
- `brave_local_search` may return a status line first, then either location results or a fallback web search result set. Treat fallback text as part of the output contract.
- `brave_summarizer` can fail with a generic summary-unavailable message if the account or upstream query does not support it.
- `tavily_search` returns a text block with repeated `Title`, `URL`, and `Content` sections.
- `tavily_extract` returns a text block with `Title`, `URL`, `Content`, and often `Raw Content`. `Content` may be empty while `Raw Content` still contains the useful payload.
- `tavily_map` returns a text block containing a base URL and numbered URLs.
- `tavily_crawl` may return only a header with no pages if the crawl constraints or page structure yield nothing useful.
- `tavily_research` returns a synthesized markdown-style report plus a source list. It is useful, but often verbose and not always tightly scoped.
- `resolve_library_id` returns ranked candidates with library ID, description, snippet count, and reputation.
- `query_docs` returns curated excerpts with source references and code samples.
- GitHub MCP tools return structured JSON objects, not prose.
- Hugging Face `_hf_whoami` returns a short text identity string; `_space_search` returns a markdown table of matching Spaces.

## Current Capability Notes

- Brave MCP is available in this environment and basic web search works.
- Tavily MCP is available in this environment and `tavily_search` works.
- Context7 is available and works well for official docs lookup.
- GitHub MCP is available for read-only PR and commit-status metadata.
- Hugging Face MCP is available for account identity and Space search.
- `brave_local_search` and `brave_summarizer` may still be account-limited.
- Tavily search quality depends heavily on the query; if results are noisy, refine the query or switch tools.

## Practical Lessons

- Use Context7 before general search for programming docs.
- Use Brave when you want lightweight discovery across the public web.
- Use Tavily when you need the body of a page, not just search snippets.
- Do not assume success from tool presence. Some tools are connected but still limited by plan, upstream support, or weak result quality.
- Watch for format mismatches. Some MCPs return structured JSON, some return markdown tables, and some return plain text blobs that need parsing.
- If a tool returns noisy but non-empty results, report that directly instead of overstating confidence.

## Empirical Notes

These observations come from local execution of every currently available MCP tool:

- `brave_web_search` worked on a simple query.
- `brave_web_search` with `summary=true` returned no web results in local testing.
- `brave_news_search`, `brave_image_search`, and `brave_video_search` worked.
- `brave_local_search` returned a fallback notice plus generic web results, which suggests either plan limitation or no location match.
- `brave_summarizer` returned a generic failure message when called directly.
- `tavily_search`, `tavily_extract`, `tavily_map`, and `tavily_research` worked.
- `tavily_crawl` completed but returned only a header and no useful pages for the tested target.
- `resolve_library_id` and `query_docs` both worked cleanly on a React query.
- GitHub `_get_pr_info` worked on a public pull request and `_get_commit_combined_status` returned an empty `statuses` array for the tested commit.
- Hugging Face `_hf_whoami` and `_space_search` both worked.

## Examples

- "Find the latest OpenAI API pricing changes." Prefer Brave or Tavily for current sources, then cite them.
- "How does `useEffectEvent` work in React?" Prefer Context7.
- "Extract the important sections from this documentation page." Prefer Tavily extract.
- "Map the docs site and find pages about auth callbacks." Prefer Tavily map or crawl.
- "Find recent interviews with Jensen Huang." Prefer Brave video search.
- "Find ramen shops in Causeway Bay." Use Brave local search only with confirmed Pro access; otherwise use general web search.
- "Show me PR metadata for Next.js PR 1." Prefer GitHub MCP.
- "Find MCP-enabled Spaces on Hugging Face." Prefer Hugging Face MCP.
