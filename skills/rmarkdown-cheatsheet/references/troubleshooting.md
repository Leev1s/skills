# Troubleshooting

## Purpose

Use this note when an R Markdown PDF cheatsheet fails to render or when the layout is technically correct but visually unstable.

## First Response

Always do this first:

1. turn on `keep_tex: true`
2. inspect the generated `.tex`
3. inspect the `.log`
4. identify whether the failure is setup, LaTeX package, layout, or content width

## Common Failure Modes

### `File 'xxx.sty' not found`

Cause:

- missing LaTeX package

Fix:

```r
tinytex::parse_install("document.log")
```

Or install directly:

```r
tinytex::tlmgr_install("enumitem")
```

### `Undefined control sequence`

Common causes:

- header file not included
- package not loaded
- copied TeX command requires another package

Fix path:

- confirm `includes: in_header: header.tex`
- confirm the command really exists in the loaded package
- remove nonessential preamble tweaks until the template is stable

### Strange errors around headings inside `multicols`

Cause:

- Markdown-generated headings interacting badly with a fragile LaTeX environment

Fix:

- replace `# Heading` with `\section*{Heading}`
- keep the raw LaTeX block boundaries explicit
- reduce inline code and special characters in the fragile section

### Tables break columns or overflow

Cause:

- wide `tabular`
- `longtable`
- booktabs-heavy output that is too wide for a single column

Fix:

- keep the table narrow
- place the table outside `multicols`
- render a compact text table instead of a formal table

### Figures disappear or move unexpectedly

Cause:

- `multicols` does not behave like normal float layout

Fix:

- keep floats out of `multicols`
- use `[H]` only when you know the object fits one column
- place wide objects between column blocks

### Long code blocks ruin the layout

Cause:

- content width exceeds column width

Fix:

- shorten the example
- use smaller snippets
- move the long code block outside the multi-column region

## Practical Heuristics

- If the error is structural, simplify the layout before changing content.
- If the error is package-related, repair TinyTeX before touching the document.
- If the problem appears only after adding a table or figure, suspect width or float behavior first.
- If a layout keeps failing inside columns, use explicit LaTeX section commands and plain paragraphs.

## Stable Debug Loop

1. render the smallest possible file
2. confirm the template compiles
3. add one section at a time
4. add tables and figures last
5. keep the last known-good `.tex` around while iterating

## Sources

- TinyTeX R guide: <https://yihui.org/tinytex/r/>
- R Markdown Cookbook, install missing packages: <https://yihui.org/rmarkdown-cookbook/install-latex-pkgs>
- R Markdown Cookbook, multi-column layout: <https://yihui.org/rmarkdown-cookbook/multi-column>
- CTAN multicol package: <https://ctan.org/pkg/multicol>
