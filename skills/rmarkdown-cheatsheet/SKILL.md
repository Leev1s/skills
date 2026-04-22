---
name: rmarkdown-cheatsheet
description: Create, debug, and optimize R Markdown PDF cheatsheets with TinyTeX and LaTeX. Use this skill whenever the user mentions R Markdown PDF rendering, TinyTeX installation or repair, LaTeX package errors, A4 landscape layouts, multi-column cheatsheets, or wants reusable .Rmd and .tex templates, even if they do not explicitly ask for a "cheatsheet" or mention TinyTeX by name.
---

# R Markdown Cheatsheet

## Overview

Use this skill for R Markdown workflows that end in compact PDF cheatsheets.

## Expected Output

When this skill is used, prefer producing:

- a short diagnosis of the setup issue, render failure, or layout tradeoff
- the minimal YAML, LaTeX header, or body changes needed to make progress
- reusable `.Rmd` and `.tex` snippets or a concrete template path when the user needs a starting point
- concrete install, render, or repair commands when the task includes TinyTeX or PDF toolchain setup

Prefer the simplest stable pipeline:

1. Install or manage TinyTeX from R.
2. Render with `rmarkdown::render()`.
3. Keep `keep_tex: true` while iterating.
4. Prefer PDF-only raw LaTeX `multicol` for A4 landscape cheatsheets.
5. Use the Cookbook custom-block pattern only when the same source must also support HTML or Beamer.

## Workflow

### 1. Verify the toolchain

Check these pieces before editing layout:

- R is available.
- `rmarkdown`, `knitr`, and `tinytex` are installed.
- Pandoc is available to `rmarkdown`.
- A LaTeX engine exists; prefer `xelatex` for Unicode or CJK-heavy cheatsheets.

If setup is missing or broken, read [references/tinytex-best-practices.md](references/tinytex-best-practices.md).

### 2. Choose the layout strategy

Use the PDF-only pattern by default:

- Use `papersize: a4`.
- Use `classoption: landscape`.
- Use `pdf_document`.
- Load `multicol` from a header file.
- Wrap the column region in raw LaTeX fenced blocks.

Read [references/a4-landscape-multicol.md](references/a4-landscape-multicol.md) for the detailed pattern.

Use the Cookbook custom-block pattern only when the output must be shared across multiple formats. It is more flexible, but also more fragile and usually unnecessary for a cheatsheet.

### 3. Start from the template assets

For a stable A4 horizontal five-column cheatsheet, start from:

- [assets/pdf-only-a4-5col/cheatsheet.Rmd](assets/pdf-only-a4-5col/cheatsheet.Rmd)
- [assets/pdf-only-a4-5col/header.tex](assets/pdf-only-a4-5col/header.tex)

This template is intentionally conservative:

- explicit A4 + landscape variables
- `xelatex`
- ultra-tight cheatsheet margins
- `multicols*` as the default cheatsheet flow
- no floating tables or figures inside columns
- no title block or centered title
- custom compact section labels inside the column environment
- a minimal header with only the list and title spacing controls that matter
- `\scriptsize` body text as the dense default

### 4. Follow the column rules

Inside `multicols`, prefer:

- short sections
- bullet lists
- short inline code
- narrow non-floating content

Avoid inside `multicols` unless you have a specific reason and have tested it:

- floating `figure` or `table`
- `longtable`
- wide `kable()` output
- long code blocks
- Markdown headings when the layout is already fragile

When in doubt, use `\section*{...}` instead of `# Heading` inside the column block.
For very dense cheatsheets, prefer an even tighter custom macro such as `\cheatsection{...}` instead of normal section commands.

For Pandoc-generated bullet lists, remember that `\tightlist` is not the whole story. The gap between a heading and the first bullet often comes from the list environment itself, so tune `\@listi` (`topsep`, `partopsep`, `parsep`, `itemsep`) before adding ad hoc negative spacing to the heading macro.

Avoid stacking multiple aggressive negative skips across `\cheatsection`, global list lengths, `\@listi`, and `\tightlist`. That often produces text overlap while saving very little space.

### 5. Debug from the generated `.tex`

When PDF rendering fails:

1. Keep `keep_tex: true`.
2. Read the generated `.tex` and `.log`.
3. Match the symptom against [references/troubleshooting.md](references/troubleshooting.md).

Do not guess blindly. Multi-column PDF failures are often caused by a small set of recurring problems:

- missing LaTeX package
- float inside `multicols`
- wide table or output block
- Markdown/LaTeX mixing issue
- stale TinyTeX installation
- over-aggressive heading/list spacing that only shows up in the generated `.tex`

## Response Pattern

When the user asks for help, keep the response direct and task-shaped:

1. State the likely failure mode or layout decision.
2. Give the smallest viable fix.
3. Point to the relevant bundled reference or template only when it will save time.
4. Prefer concrete renderable examples over abstract discussion.

## TinyTeX Guidance

Prefer installing TinyTeX from R instead of using another package manager when the goal is R Markdown PDF output.

Use this default sequence:

```r
install.packages("tinytex")
tinytex::install_tinytex()
tinytex::is_tinytex()
```

Use `tinytex::parse_install()` for missing-package errors and `tinytex::tlmgr_update()` to refresh the installation.

Do not migrate a working LaTeX installation just for uniformity unless the user explicitly wants that change.

## Layout Guidance

For A4 landscape cheatsheets, prefer:

```yaml
papersize: a4
classoption:
  - landscape
fontsize: 10pt
geometry: margin=0.18in
```

Prefer `multicols` over class-level two-column mode when you need five columns or want to switch layouts inside a document.

Use `multicols*` when you want the content to fill one column before moving to the next. Switch back to normal `multicols` only when you explicitly want final-column balancing.
For actual cheatsheets, suppress `\maketitle`, tighten body text inside the column block, and keep spacing control simple rather than layering multiple overlapping length tweaks.

## Resources

Read the following files as needed:

- [references/tinytex-best-practices.md](references/tinytex-best-practices.md)
- [references/a4-landscape-multicol.md](references/a4-landscape-multicol.md)
- [references/troubleshooting.md](references/troubleshooting.md)

Reuse these template assets instead of recreating them:

- [assets/pdf-only-a4-5col/cheatsheet.Rmd](assets/pdf-only-a4-5col/cheatsheet.Rmd)
- [assets/pdf-only-a4-5col/header.tex](assets/pdf-only-a4-5col/header.tex)
