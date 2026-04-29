---
name: macos-fonts
description: Configure, debug, select, and verify fonts on macOS across Font Book, local font files, Quarto (.qmd), R Markdown (.Rmd), HTML/CSS, PDF rendering, LaTeX fontspec/xeCJK, and R graphics. Use this skill whenever the user mentions macOS fonts, Font Book, installed .otf/.ttf/.ttc files, variable fonts, CJK or Chinese report fonts, Source Han, Songti, Heiti, STIX, IBM Plex Mono, fontspec errors, missing fonts, or fonts that work in one app but fail in another.
---

# macOS Fonts

## Workflow

1. Identify the rendering layer before editing files:
   - macOS font installation or Font Book visibility.
   - HTML/browser CSS.
   - Quarto or R Markdown document text.
   - LaTeX PDF through XeLaTeX or LuaLaTeX.
   - R plot text through `systemfonts`, `ragg`, cairo, or a PDF device.

2. Verify the relevant toolchain:
   - `quarto --version`
   - `Rscript -e 'rmarkdown::pandoc_version(); packageVersion("knitr")'`
   - `which xelatex lualatex tlmgr`
   - `env TMPDIR=/private/tmp quarto check` when Quarto runs inside Codex.

3. Probe exact font names and files before choosing YAML or CSS values:
   - Run `scripts/probe-macos-fonts.sh "Font Name" ...`.
   - Check the common macOS font folders: `~/Library/Fonts`, `/Library/Fonts`, `/System/Library/Fonts`, and `/System/Library/Fonts/Supplemental`.
   - Treat Font Book/browser visibility, `fc-match`, `luaotfload-tool`, and R `systemfonts` as separate answers. A font visible to one layer may still fail in another.

4. Configure document text separately from figure text:
   - HTML document text: CSS `font-family`.
   - PDF document text: Pandoc/LaTeX variables such as `mainfont`, `mathfont`, `monofont`, `CJKmainfont`.
   - R plot text: knitr graphics device plus ggplot/theme font family; register user font files with `systemfonts::register_font()` when needed.

5. Prefer the stable PDF path first:
   - Use `xelatex` for Unicode/CJK documents unless there is a specific LuaLaTeX requirement.
   - Prefer static OpenType `.otf` or static TrueType `.ttf` fonts for XeLaTeX PDF.
   - Treat `.ttc` font collections as usable but more fragile; verify with a minimal XeLaTeX smoke file and use `FontIndex` when needed.
   - Avoid variable fonts and web fonts (`.woff`, `.woff2`) for XeLaTeX PDF.
   - Use `CJKmainfont` for Chinese text; on this macOS setup, `Songti SC` is the preferred formal Chinese body font for PDF.
   - Use `STSong` or `Songti TC` as Songti variants; use `Heiti SC` or `Hiragino Sans GB` for headings or sans-serif layouts.
   - For local OTF code fonts that TeX cannot find by family name, set `monofont` to the file stem and add `monofontoptions` with `Path`, `UprightFont`, `BoldFont`, `ItalicFont`, and `BoldItalicFont`.

6. Verify with a minimal smoke file before changing a large report or app.
   - Render one output at a time while debugging.
   - Keep `.tex` files with `keep-tex: true`.
   - Read `.log` for `fontspec`, `xeCJK`, `luaotfload`, and graphics-device errors.

## Important Rules

- Do not assume browser/Font Book visibility means PDF support.
- Do not assume LaTeX document fonts apply to ggplot figures.
- Do not put HTML `<style>` inside R Markdown `header-includes` when rendering PDF; use a CSS file or raw HTML block for HTML-only styling.
- Use R booleans in R chunks: `TRUE` and `FALSE`, not YAML-style `true` and `false`.
- Treat Source Han Serif VF as HTML-safe but PDF-unsafe on this machine. XeLaTeX cannot load it by name; LuaLaTeX can find it but fails during PDF embedding with `loca table not found`.
- If the user wants Source Han in PDF, install or locate a static OTF/TTF Source Han Serif SC family and probe that static family before editing the document.

## References

- Read [references/font-chain.md](references/font-chain.md) for QMD/RMD snippets and failure-mode guidance.
