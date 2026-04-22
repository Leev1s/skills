# Agent Skills Spec

This repository follows a simple skill layout:

```text
skills/
  <skill-name>/
    SKILL.md
    assets/
    references/
    scripts/        # optional
    evals/          # optional
```

## Required

- Every skill directory must contain `SKILL.md`.
- `SKILL.md` must include YAML frontmatter with at least:
  - `name`
  - `description`

## Optional

- `assets/` for templates and static files.
- `references/` for supporting documentation loaded only when needed.
- `scripts/` for deterministic helpers.
- `evals/` for evaluation prompts and metadata.
- `agents/` for platform-specific integration metadata when needed.

## Guidance

- Keep skill instructions focused on a single workflow.
- Keep bundled resources directly relevant to the skill.
- Prefer concrete examples and reusable templates.
