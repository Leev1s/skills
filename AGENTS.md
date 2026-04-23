# AGENTS.md

## Repo Purpose

- This repository stores installable skills.
- Skills must live under `skills/<skill-name>/`.

## Skill Structure

Each skill should follow this structure:

```text
skills/<skill-name>/
  SKILL.md
  references/           # optional
  scripts/              # optional
  assets/               # optional
  evals/evals.json      # optional but recommended for new skills
```

Rules:

- `SKILL.md` is required and must include YAML frontmatter with `name` and `description`.
- Keep the skill body concise; move long technical material to `references/`.
- Keep instructions concrete and linear. Avoid unnecessary abstractions.
- Add only the changes required by the task. Do not refactor unrelated skills.

## Writing Principles

- Follow Occam's Razor.
- Prefer straightforward, linear logic.
- Avoid over-engineering.
- Do not add features, wrappers, or compatibility shims that were not requested.
- Add comments only where logic is not self-evident.
