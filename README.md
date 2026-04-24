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
| `mineru-md` | Parse supported documents to Markdown via MinerU lightweight agent API. |
| `resume-master` | Turn student-style resumes, cover letters, interview answers, LinkedIn summaries, and career stories into employer-facing evidence of role fit. |
| `rmarkdown-cheatsheet` | Build, debug, and optimize R Markdown PDF cheatsheets with TinyTeX and LaTeX. |

## Skill Format

```text
skills/<skill-name>/
  SKILL.md
  references/           # optional
  scripts/              # optional
  assets/               # optional
  evals/evals.json      # optional
```
