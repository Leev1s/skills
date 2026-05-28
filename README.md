# Skills

Public repository for agent skills.

## Repository Layout

- `skills/` contains installable skill folders.
- Each skill lives in `skills/<skill-name>/`.
- Each skill must include `SKILL.md` with YAML frontmatter containing `name` and `description`.
- Skills may include `references/`, `scripts/`, `assets/`, and `evals/evals.json` when needed.

## Included Skills

| Skill | Purpose |
| --- | --- |
| `mcp-guide` | Route MCP usage to the best available tool for the task. |
| `macos-fonts` | Configure, debug, select, and verify fonts on macOS across Font Book, local font files, Quarto, R Markdown, HTML/CSS, PDF rendering, LaTeX, and R graphics. |
| `mineru-md` | Parse supported documents to Markdown via MinerU lightweight agent API, with a Python primary workflow and curl/PowerShell fallbacks for macOS, Linux, and Windows. |
| `resume-master` | Turn student-style resumes, cover letters, interview answers, LinkedIn summaries, and career stories into employer-facing evidence of role fit. |
| `qmd-cheatsheet` | Build, debug, and optimize Quarto PDF cheatsheets with XeLaTeX, TinyTeX, and dense A4 multi-column layout patterns. |
| `see` | Use the S.EE `see` CLI for short URLs, text/paste entries, file uploads, image hosting, domains, tags, and JSON scripting. |

## Skill Format

```text
skills/<skill-name>/
  SKILL.md
  references/           # optional
  scripts/              # optional
  assets/               # optional
  evals/evals.json      # optional
```
