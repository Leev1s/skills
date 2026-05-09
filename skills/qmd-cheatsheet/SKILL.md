---
name: qmd-cheatsheet
description: Create, debug, and optimize Quarto `.qmd` PDF cheatsheets, especially dense A4 landscape multi-column sheets rendered with XeLaTeX. Use this skill whenever the user mentions Quarto cheatsheets, `.qmd` cram sheets, A4 landscape PDF notes, multi-column formula sheets, XeLaTeX/CJK cheatsheet layout, or wants to preserve/tune proven compact PDF layout details. It can also help with closely related R Markdown cheatsheet workflows when Quarto-specific guidance is not required.
---

# QMD Cheatsheet

## Overview

Use this skill for Quarto-first cheatsheet workflows that end in compact PDF output. The default target is a dense A4 landscape sheet with narrow columns, readable formulas, and stable XeLaTeX behavior.

This skill should prefer proven Quarto patterns over generic LaTeX advice:

- Quarto `.qmd` source
- `pdf-engine: xelatex`
- raw LaTeX fenced blocks for `multicols*`
- a paired header file for spacing/fonts/macros
- temporary `keep-tex: true` only when debugging render failures

R Markdown is still in scope, but only as a nearby compatibility case. If the user is starting fresh, default to Quarto.

## Expected output

When this skill is used, prefer producing:

- a short diagnosis of the layout or rendering problem
- the smallest viable YAML/header/body changes
- reusable `.qmd` and `.tex` snippets or a concrete template path
- concrete render or repair commands for Quarto, XeLaTeX, or TinyTeX when needed

## Workflow

### 1. Verify the toolchain

Check the stack before changing layout:

- Quarto is available.
- XeLaTeX is available.
- The header file path is correct.
- If the workflow is R-backed or TinyTeX-backed, verify that path too.

Prefer `xelatex` for Unicode or CJK-heavy cheatsheets.

If setup is broken, read [references/tinytex-best-practices.md](references/tinytex-best-practices.md).

### 2. Choose the layout pattern

Use the PDF-only Quarto pattern by default:

- `format: pdf`
- `documentclass: article`
- `papersize: a4`
- `pdf-engine: xelatex`
- `classoption: [fleqn]`
- aggressive but real A4 landscape geometry
- `include-in-header: header.tex`
- raw LaTeX fenced blocks for `\begin{multicols*}{5}` and `\end{multicols*}`

For formula-heavy sheets, prefer 5 columns rather than 6. Six-column layouts often look denser in theory but become visually grey and harder to scan in practice.

Read [references/a4-landscape-multicol.md](references/a4-landscape-multicol.md) for the concrete pattern.

### 3. Start from the bundled template

For a stable A4 horizontal five-column Quarto cheatsheet, start from:

- [assets/pdf-only-a4-5col/cheatsheet.qmd](assets/pdf-only-a4-5col/cheatsheet.qmd)
- [assets/pdf-only-a4-5col/header.tex](assets/pdf-only-a4-5col/header.tex)

This template is intentionally conservative:

- explicit A4 + landscape geometry
- `xelatex`
- `fleqn` for left-aligned display math
- `multicols*` as the default content flow
- no title block
- compact section spacing
- CJK-safe defaults can be layered in when needed

### 4. Follow the column rules

Inside `multicols`, prefer:

- short sections
- formulas
- compact bullet lists
- short answer templates
- narrow tables you have checked for width

Avoid inside `multicols` unless you have tested it carefully:

- floating figures or tables
- `longtable`
- wide tabular output
- long code blocks
- bulky console output

When the sheet is fragile, prefer header-level spacing control over ad hoc negative `\vspace` in the body.

### 5. Debug from the generated `.tex`

When PDF rendering fails:

1. temporarily enable `keep-tex: true`
2. inspect the generated `.tex`
3. inspect the `.log`
4. determine whether the issue is setup, package, font, layout, or content width

Do not guess blindly. Multi-column PDF failures usually come from a small recurring set:

- missing LaTeX package
- font mismatch
- float inside `multicols`
- content too wide for one column
- Markdown/LaTeX interaction issues
- over-aggressive spacing tweaks

## Response pattern

Keep the answer task-shaped:

1. State the likely failure mode or layout choice.
2. Give the smallest working fix.
3. Point to the bundled template or reference only when it saves time.
4. Prefer renderable examples over abstract discussion.

## Layout guidance

For A4 landscape Quarto cheatsheets, prefer something close to:

```yaml
format:
  pdf:
    documentclass: article
    papersize: a4
    pdf-engine: xelatex
    classoption:
      - fleqn
    geometry:
      - a4paper
      - landscape
      - top=3.8mm
      - bottom=3.8mm
      - left=4.2mm
      - right=4.2mm
    include-in-header: header.tex
    number-sections: false
```

For actual cheatsheets:

- suppress the title block
- keep body text around the 5pt range only when the content is truly dense
- keep display math left-aligned and compact
- prefer `multicols*` when you want column-by-column fill
- use `\raggedcolumns`

## Verification

Render normally with:

```bash
TMPDIR=/private/tmp quarto render cheatsheet.qmd --to pdf
```

If you need the generated `.tex` for debugging, rerender with:

```bash
TMPDIR=/private/tmp quarto render cheatsheet.qmd --to pdf -M keep-tex:true
```

Then inspect:

```bash
rg -n "LaTeX Error|Overfull|Missing character|font|Font|Output written" cheatsheet.log
```

If Quarto does not leave a `.log` in the expected place, run `xelatex -interaction=nonstopmode cheatsheet.tex` in the output directory to create one.

## Resources

Read these files as needed:

- [references/a4-landscape-multicol.md](references/a4-landscape-multicol.md)
- [references/tinytex-best-practices.md](references/tinytex-best-practices.md)
- [references/troubleshooting.md](references/troubleshooting.md)

Reuse these template assets instead of rebuilding them:

- [assets/pdf-only-a4-5col/cheatsheet.qmd](assets/pdf-only-a4-5col/cheatsheet.qmd)
- [assets/pdf-only-a4-5col/header.tex](assets/pdf-only-a4-5col/header.tex)
