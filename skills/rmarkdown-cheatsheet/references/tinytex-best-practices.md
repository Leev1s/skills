# TinyTeX Best Practices

## Purpose

Use this note when the task is to install, verify, update, or repair TinyTeX for R Markdown PDF workflows.

## Recommended Install Path

Prefer installing TinyTeX from R:

```r
install.packages("tinytex")
tinytex::install_tinytex()
tinytex::is_tinytex()
```

Why this path is preferred:

- it is the path documented by TinyTeX and the R Markdown Cookbook
- it installs into a user-writable location
- it avoids mixing R Markdown PDF tooling with unrelated package managers
- the `tinytex` package can help detect and repair missing LaTeX packages

## Verification Checklist

After installation, verify:

```r
tinytex::is_tinytex()
tinytex::tlmgr("--version")
rmarkdown::pandoc_available()
```

At the shell, useful checks are:

```bash
which pdflatex
which xelatex
which latexmk
```

## Best Practices

### Prefer `xelatex` for Unicode-heavy cheatsheets

Use `xelatex` when the cheatsheet includes:

- Chinese or mixed CJK text
- system fonts
- broader Unicode needs

In YAML:

```yaml
output:
  pdf_document:
    latex_engine: xelatex
```

### Keep the install managed from R

Preferred maintenance commands:

```r
tinytex::tlmgr_update()
tinytex::parse_install()
tinytex::reinstall_tinytex()
```

Use them this way:

- `tinytex::tlmgr_update()` to refresh package metadata and installed packages
- `tinytex::parse_install()` after a LaTeX error log reports a missing `.sty` or font package
- `tinytex::reinstall_tinytex()` when the installation is stale or badly broken

### Avoid unnecessary migration

If a machine already has a working LaTeX installation and R Markdown renders successfully, do not migrate just to standardize the package manager. Only migrate when the user explicitly wants that change or when the current installation is broken and replacement is the simplest fix.

### Prefer user-space installs

TinyTeX is designed to avoid admin-only install paths. This is usually the right choice for local R Markdown work.

## Common Repair Patterns

### Missing style or font package

Typical errors:

- `File 'xxx.sty' not found`
- missing font package
- encoding file not found

Preferred fix path:

```r
tinytex::parse_install("build.log")
```

If you already know the package:

```r
tinytex::tlmgr_install("enumitem")
```

### Package database is outdated

```r
tinytex::tlmgr_update()
```

### Installation is recognized but behaving inconsistently

```r
tinytex::reinstall_tinytex()
```

## Minimal R Setup Script

```r
if (!requireNamespace("tinytex", quietly = TRUE)) {
  install.packages("tinytex")
}

if (!tinytex::is_tinytex()) {
  tinytex::install_tinytex()
}
```

## Sources

- TinyTeX home: <https://yihui.org/tinytex/>
- TinyTeX and R usage: <https://yihui.org/tinytex/r/>
- R Markdown Cookbook, Install LaTeX: <https://yihui.org/rmarkdown-cookbook/install-latex>
- R Markdown Cookbook, Install missing packages: <https://yihui.org/rmarkdown-cookbook/install-latex-pkgs>
