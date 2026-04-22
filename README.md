# Skills

Public repository for agent skills, modeled after the high-level structure of [anthropics/skills](https://github.com/anthropics/skills).

## Repository Layout

- `.claude-plugin/` contains lightweight marketplace-style metadata.
- `skills/` contains installable skill folders.
- `spec/` contains repository-level notes about the expected shape of a skill.
- `template/` contains a minimal starter `SKILL.md`.

## Included Skills

- `rmarkdown-cheatsheet`: Build, debug, and optimize R Markdown PDF cheatsheets with TinyTeX and LaTeX.

## Notes

This repository intentionally keeps the top-level structure simple and close to the public Anthropic skills repository:

- root `README.md`
- root `.gitignore`
- root `THIRD_PARTY_NOTICES.md`
- `.claude-plugin/`
- `skills/`
- `spec/`
- `template/`
