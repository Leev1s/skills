# A4 Landscape Multi-Column PDF

## Purpose

Use this note when the task is to create or refine a compact Quarto PDF cheatsheet, especially an A4 landscape layout with five columns.

## Recommended Pattern

Prefer this structure for PDF-only cheatsheets:

1. Quarto `.qmd`
2. `format: pdf`
3. `pdf-engine: xelatex`
4. `papersize: a4`
5. `classoption: [fleqn]`
6. `include-in-header: header.tex`
7. raw LaTeX fenced blocks for `\begin{multicols*}{5}` and `\end{multicols*}`

This is simpler and more reliable than abstract layout tricks when the real goal is a dense, exam-oriented PDF.

For a real cheatsheet, remove the default title block. It wastes space and makes the document read like a report.

## Minimal YAML

```yaml
---
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
execute:
  echo: false
  warning: false
  message: false
---
```

## Minimal Header File

```tex
\usepackage{xeCJK}
\usepackage{multicol}
\usepackage{enumitem}
\usepackage{amsmath,amssymb,mathtools}
\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlength{\columnsep}{1.35mm}
\setlength{\columnseprule}{0pt}
\setlength{\multicolsep}{0pt}
\setlength{\mathindent}{0pt}
\raggedcolumns
\makeatletter
\@secpenalty=0
\@beginparpenalty=0
\@endparpenalty=0
\clubpenalty=0
\widowpenalty=0
\displaywidowpenalty=0
\makeatother
\AtBeginDocument{
  \fontsize{5.0pt}{5.65pt}\selectfont
  \setlength{\abovedisplayskip}{0.35ex}
  \setlength{\belowdisplayskip}{0.35ex}
}
```

For mixed Chinese-English content on macOS, add:

```tex
\setCJKmainfont{Songti SC}
\setCJKmonofont{Heiti SC}
\XeTeXlinebreaklocale "zh"
\XeTeXlinebreakskip=0pt plus 0.08em
```

## Minimal Body Pattern

````md
```{=latex}
\begin{multicols*}{5}
```

# Topic

Short retrieval-first notes.

$$
\sqrt n(\hat\theta-\theta)\rightsquigarrow N(0,I(\theta)^{-1})
$$

```{=latex}
\end{multicols*}
```
````

## Why this pattern is preferred

- Quarto handles the PDF metadata cleanly.
- `multicols*` supports five columns directly.
- raw LaTeX fences are explicit and easy to debug.
- temporary `keep-tex: true` makes failures traceable when debugging.
- `fleqn` reduces overflow pain in narrow columns.
- suppressing the title block recovers useful space.

## Five-column layout notes

For five columns on A4 landscape:

- prefer 5 columns over 6 for formula-heavy content
- keep body text near `5.0pt/5.65pt`
- keep margins aggressively small but real
- remove the column separator rule
- use nonzero display skips
- keep sections short
- avoid manual page breaks
- use `\raggedcolumns`

## Spacing note for headings and lists

When a heading is followed by a bullet list, the visible gap often comes from the list environment, not from the heading itself. If a dense cheatsheet still looks loose after headings:

- inspect the generated `.tex`
- tune list spacing centrally
- avoid stacking multiple negative skips across headings and lists

Large negative spacing often creates overlap while saving very little real space.

## Debug note

Do not keep generated `.tex` files by default. Render normally first. Turn on `keep-tex: true` only when you need to inspect the generated TeX during debugging.

## Content rules inside `multicols`

Good fits:

- brief explanations
- formulas
- compact bullet lists
- answer templates
- narrow tables checked for width

Poor fits:

- floating figures
- floating tables
- `longtable`
- wide tabular output
- long code blocks
- long console output

If something needs more than one column, close `multicols`, place it, then reopen the columns.
