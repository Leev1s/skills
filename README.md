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
| `macos-fonts` | Configure, debug, select, and verify fonts on macOS across Font Book, local font files, Quarto, R Markdown, HTML/CSS, PDF rendering, LaTeX, and R graphics. |
| `resume-master` | Turn student-style resumes, cover letters, interview answers, LinkedIn summaries, and career stories into employer-facing evidence of role fit. |
| `qmd-cheatsheet` | Build, debug, and optimize Quarto PDF cheatsheets with XeLaTeX, TinyTeX, and dense A4 multi-column layout patterns. |
| `quarto-authoring` | Write Quarto `.qmd` documents (YAML, code cells, cross-references, figures, tables, citations, callouts, layouts, Mermaid, shortcodes, extensions, linting) and migrate R Markdown, bookdown, xaringan, distill, and blogdown projects to Quarto. Self-hosted fork of `posit-dev/skills@quarto-authoring` after upstream deletion. |
| `see` | Use the S.EE `see` CLI for short URLs, text/paste entries, file uploads, image hosting, domains, tags, and JSON scripting. |
| `polymarket-cli` | Use the `polymarket` CLI for prediction-market reads (markets, events, CLOB prices/books, positions, leaderboards) and writes (limit/market orders, CTF split/merge/redeem, approvals, bridge) on Polygon, including the proxy-wallet (Gnosis Safe) signing model and pUSD collateral. |

## Skill Format

```text
skills/<skill-name>/
  SKILL.md
  references/           # optional
  scripts/              # optional
  assets/               # optional
  evals/evals.json      # optional
```
