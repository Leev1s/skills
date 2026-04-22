# A4 Landscape Multi-Column PDF

## Purpose

Use this note when the task is to create or refine a compact R Markdown PDF cheatsheet, especially an A4 horizontal layout with five columns.

## Recommended Pattern

Prefer this structure for PDF-only cheatsheets:

1. `pdf_document`
2. `latex_engine: xelatex`
3. `papersize: a4`
4. `classoption: landscape`
5. `includes: in_header: header.tex`
6. raw LaTeX fenced blocks for `\begin{multicols*}{5}` and `\end{multicols*}`

This is simpler and more reliable than trying to force plain Markdown headings and complex tables to coexist inside an ad hoc LaTeX environment.

For an actual cheatsheet, do not keep the default centered title block. It wastes valuable space and visually reads like a report instead of a reference sheet.

## Minimal YAML

```yaml
---
title: "A4 Landscape Five-Column Cheatsheet"
output:
  pdf_document:
    latex_engine: xelatex
    keep_tex: true
    includes:
      in_header: header.tex
papersize: a4
classoption:
  - landscape
fontsize: 10pt
geometry: margin=0.18in
---
```

## Minimal Header File

```tex
\usepackage{multicol}
\AtBeginDocument{\let\maketitle\relax}
\setlength{\columnsep}{0.08in}
\setlength{\multicolsep}{0pt}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\abovedisplayskip}{2pt}
\setlength{\belowdisplayskip}{2pt}
\linespread{0.9}
\pagestyle{empty}
\makeatletter
\def\@listi{%
  \leftmargin 0.9em
  \labelsep 0.25em
  \topsep 0pt
  \partopsep 0pt
  \parsep 0pt
  \itemsep 0pt
}
\let\@listI\@listi
\makeatother
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}%
  \setlength{\parsep}{0pt}%
  \setlength{\parskip}{0pt}%
}
\newcommand{\cheatsection}[1]{\par\vspace{0.06em}{\bfseries\footnotesize #1}\par\vspace{0.02em}}
```

## Minimal Body Pattern

````md
```{=latex}
\begin{multicols*}{5}
\raggedcolumns
\scriptsize
```

\cheatsection{Topic}
Short content here.

```{=latex}
\end{multicols*}
```
````

## Why this pattern is preferred

- `multicol` supports more than two columns
- the environment can start and stop within a document
- raw LaTeX fences are explicit and easier to debug
- `keep_tex: true` makes failures traceable
- compact custom section labels waste less space than default headings
- suppressing `\maketitle` prevents a report-style title block

## Font-size note

Standard LaTeX article classes usually support `10pt`, `11pt`, and `12pt`. Use `10pt` as the safe default, then tighten the body inside the columns with `\footnotesize` or `\scriptsize`.

If a cheatsheet needs a true document-wide `8pt`, switch to an extended class such as `extarticle`. That is an advanced option and may require installing extra class files in TinyTeX first.

## When to use the Cookbook custom-block pattern instead

Use the Cookbook custom-block approach only when:

- the same source must support HTML and PDF
- you need Div-based structure for multiple output formats
- you are willing to maintain extra header definitions

That pattern is useful, but it is not the simplest answer for a PDF-only cheatsheet.

## Five-column layout notes

For five columns on A4 landscape:

- keep the base font size safe at `10pt`
- tighten the actual cheatsheet body with `\scriptsize` when density matters
- keep margins aggressively small
- remove the column separator rule
- keep sections short
- suppress the title block
- prefer a custom macro such as `\cheatsection{}` over default section styling
- use `multicols*` when a cheatsheet should fill one column before moving to the next
- switch back to normal `multicols` only when balanced final columns are actually desired

## Spacing Note for Pandoc Lists

When a heading is followed immediately by a bullet list, the visible gap is often created at `\begin{itemize}` time, not by `\tightlist` alone. If a compact cheatsheet still shows too much space after headings, inspect the generated `.tex` and tune `\@listi` first.

Keep the fix minimal:

- prefer `topsep 0pt`, `partopsep 0pt`, `parsep 0pt`, `itemsep 0pt`
- only add small positive/zero spacing in `\cheatsection`
- avoid layering several negative skips across both headings and lists

Large negative values can make adjacent sections overlap while providing very little real gain.

## Content rules inside `multicols`

Good fits:

- brief explanations
- command lists
- formulas
- compact bullet lists
- manually controlled small graphics

Poor fits:

- floating figures
- floating tables
- `longtable`
- wide `kable()` output
- long console output

If a figure or table needs width beyond one column, close the `multicols` block, place the object, then reopen the columns.

## Sources

- R Markdown PDF document guide: <https://bookdown.org/yihui/rmarkdown/pdf-document.html>
- R Markdown Cookbook, multi-column layout: <https://yihui.org/rmarkdown-cookbook/multi-column>
- R Markdown Cookbook, LaTeX variables: <https://yihui.org/rmarkdown-cookbook/latex-variables>
- Pandoc variables manual: <https://pandoc.org/MANUAL.html>
- CTAN multicol package: <https://ctan.org/pkg/multicol>
