# macOS Font Chain Reference

## Mental Model

macOS font work often crosses several font systems:

- Font Book and local font files in user, system, and supplemental font folders.
- Browser HTML: CSS font family stacks.
- Pandoc PDF: YAML variables passed into a LaTeX template.
- LaTeX: `fontspec`, plus `xeCJK` for XeLaTeX or `luatexja-fontspec` for LuaLaTeX.
- R figures: the knitr graphics device, usually independent from the PDF document font.

Official references:

- Quarto PDF fonts: https://quarto.org/docs/output-formats/pdf-basics.html#fonts
- Quarto PDF engines: https://quarto.org/docs/output-formats/pdf-engine.html
- Pandoc LaTeX variables: https://pandoc.org/MANUAL.html#variables-for-latex
- fontspec manual: https://mirrors.ctan.org/macros/unicodetex/latex/fontspec/fontspec.pdf
- R `pdf()` device: https://search.r-project.org/R/refmans/grDevices/html/pdf.html
- Adobe Source Han Serif: https://github.com/adobe-fonts/source-han-serif

## macOS Font Locations

Check these folders first when the user says a font is installed locally:

```text
~/Library/Fonts
/Library/Fonts
/System/Library/Fonts
/System/Library/Fonts/Supplemental
```

File names are useful hints, but family names used by CSS, LaTeX, and R can differ from file names. Probe the family name with `scripts/probe-macos-fonts.sh` before editing YAML, CSS, or R code.

## XeLaTeX Font Format Decision

Use this order for Quarto/R Markdown PDF rendered through XeLaTeX:

| Format | Use with XeLaTeX | Guidance |
| --- | --- | --- |
| Static `.otf` | Best | Prefer for local academic/report fonts, especially CJK fonts installed by file. |
| Static `.ttf` | Good | Stable for many system fonts and Latin/code fonts. |
| `.ttc` / `.otc` collections | Usable with caution | Verify with a minimal smoke file; use `FontIndex` or a known family name when needed. |
| Type 1 TeX fonts | Legacy | Fine for TeX-packaged legacy fonts, not ideal for local font workflows. |
| Variable fonts (`VF`) | Avoid for XeLaTeX | Use LuaLaTeX only when there is a strong reason, and still smoke-test PDF embedding. |
| `.woff` / `.woff2` | Avoid | Web formats; use them for HTML CSS, not XeLaTeX PDF. |

Practical rule: for formal PDF output, install static OTF/TTF. For Source Han, use a static Source Han Serif SC OTF/TTF family rather than `SourceHanSerif-VF.otf.ttc`.

When using local font files by path, prefer explicit family files:

```yaml
monofont: "IBMPlexMono"
monofontoptions:
  - Path=/Users/lev1s/Library/Fonts/
  - UprightFont=*-Regular.otf
  - BoldFont=*-Bold.otf
  - ItalicFont=*-Italic.otf
  - BoldItalicFont=*-BoldItalic.otf
```

For a TTC collection that must be used directly, test a small `.tex` file first and consider a `FontIndex`-based LaTeX header rather than guessing the family name.

## QMD Pattern

```yaml
format:
  html:
    theme: cosmo
    embed-resources: true
    include-in-header:
      - text: |
          <style>
          body { font-family: "STIX Two Text", "Source Han Serif VF", "Songti SC", serif; }
          code, pre { font-family: "IBM Plex Mono", ui-monospace, monospace; }
          </style>
  pdf:
    pdf-engine: xelatex
    keep-tex: true
    mainfont: "STIX Two Text"
    mathfont: "STIX Two Math"
    monofont: "IBMPlexMono"
    monofontoptions:
      - Path=/Users/lev1s/Library/Fonts/
      - UprightFont=*-Regular.otf
      - BoldFont=*-Bold.otf
      - ItalicFont=*-Italic.otf
      - BoldItalicFont=*-BoldItalic.otf
    CJKmainfont: "Songti SC"
    CJKsansfont: "Songti SC"
    CJKmonofont: "Songti SC"
knitr:
  opts_chunk:
    dev: "ragg_png"
```

Use `ragg_png` for robust figure rendering when local plot fonts matter. It rasterizes figure text and avoids PDF font embedding problems inside figures.

## Formal Chinese Font Choices

Use this order when the user asks for formal Chinese writing on the current macOS setup:

| Font | Use | PDF status |
| --- | --- | --- |
| `Songti SC` | Preferred simplified Chinese body text | Verified with XeLaTeX |
| `STSong` | Traditional Songti-compatible fallback | Verified with XeLaTeX |
| `Songti TC` | Traditional Chinese body text | Verified with XeLaTeX |
| `Heiti SC` | Simplified Chinese headings, labels, UI-like reports | Verified with XeLaTeX |
| `Heiti TC` | Traditional Chinese headings, labels | Verified with XeLaTeX |
| `Hiragino Sans GB` | Modern sans-serif simplified Chinese | Verified with XeLaTeX |
| `Arial Unicode MS` | Last-resort broad Unicode fallback | Verified with XeLaTeX, not preferred for typography |
| `Hiragino Mincho ProN` | Japanese Mincho, not simplified Chinese body text | Avoid for simplified Chinese; missing characters were observed |
| `Source Han Serif * VF` | HTML body text, not PDF | PDF embedding fails from the current VF TTC file |

When the user wants a Source Han look in PDF, do not keep retrying `SourceHanSerif-VF.otf.ttc`. Install or locate a static OTF/TTF Source Han Serif SC family, then set `CJKmainfont` to that static family name and rerun the probe.

## Current Source Han VF Finding

The current local file is:

```text
/Users/lev1s/Library/Fonts/SourceHanSerif-VF.otf.ttc
```

Observed behavior:

- `fc-match` sees `Source Han Serif VF`, `Source Han Serif SC VF`, `Source Han Serif TC VF`, and related subfamilies.
- `luaotfload-tool --find` resolves the TTC and subfont indexes.
- XeLaTeX reports that `Source Han Serif VF` cannot be found when used as `CJKmainfont`.
- LuaLaTeX creates a font family but fails to produce PDF with `loca table not found`.
- R `systemfonts::match_fonts()` falls back to Helvetica for Source Han VF on this setup.

Conclusion: use Source Han VF in HTML CSS stacks only; avoid it for LaTeX PDF and R plot text unless the font installation changes.

## RMD Pattern

```yaml
output:
  html_document:
    self_contained: true
  pdf_document:
    latex_engine: xelatex
    keep_tex: true
mainfont: "STIX Two Text"
mathfont: "STIX Two Math"
monofont: "IBMPlexMono"
monofontoptions:
  - Path=/Users/lev1s/Library/Fonts/
  - UprightFont=*-Regular.otf
  - BoldFont=*-Bold.otf
  - ItalicFont=*-Italic.otf
  - BoldItalicFont=*-BoldItalic.otf
CJKmainfont: "Songti SC"
CJKsansfont: "Songti SC"
CJKmonofont: "Songti SC"
```

Add HTML-only CSS as raw HTML, not `header-includes`, when the same RMD also renders PDF:

````markdown
```{=html}
<style>
body { font-family: "STIX Two Text", "Source Han Serif VF", "Songti SC", serif; }
code, pre { font-family: "IBM Plex Mono", ui-monospace, monospace; }
</style>
```
````

## R Plot Fonts

Document fonts and ggplot fonts are separate. A setup chunk can register local font files for R-side devices:

```r
library(systemfonts)

register_font(
  name = "IBM Plex Mono Local",
  plain = "/Users/lev1s/Library/Fonts/IBMPlexMono-Regular.otf",
  bold = "/Users/lev1s/Library/Fonts/IBMPlexMono-Bold.otf",
  italic = "/Users/lev1s/Library/Fonts/IBMPlexMono-Italic.otf",
  bolditalic = "/Users/lev1s/Library/Fonts/IBMPlexMono-BoldItalic.otf"
)
```

Use `theme_minimal(base_family = "Songti SC")` or another font that `systemfonts::match_fonts()` resolves correctly. If it falls back to Helvetica, register explicit font files or choose another local font.

## Failure Modes

- `fontspec` cannot find a font: check exact family name with `fc-match` and TeX visibility with `luaotfload-tool --find`.
- Code font exists but TeX cannot find it: use explicit `Path` and font-file patterns in `monofontoptions`.
- Local font exists only as `.woff` or `.woff2`: use it in HTML only; install a static `.otf` or `.ttf` for XeLaTeX PDF.
- Local font is a variable font: do not use it as the first PDF choice; find the static OTF/TTF build or switch to a verified non-variable local font.
- CJK characters fail in PDF: use `xelatex` and set `CJKmainfont`; verify the font has Chinese glyph coverage.
- Source Han Serif VF variable TTC fails with `loca table not found`: use a static OTF/TTF for PDF, or use another stable local CJK font such as `Songti SC`.
- `Hiragino Mincho ProN` can be found by TeX but is not a good simplified Chinese body font; test actual Chinese sample text before using it.
- R plot text ignores PDF YAML fonts: set knitr `dev`, register fonts with `systemfonts`, and set ggplot `base_family`.
- R Markdown PDF fails with `Missing \begin{document}` after adding CSS: remove HTML from `header-includes`; use HTML-only raw block or a CSS file for HTML output.
