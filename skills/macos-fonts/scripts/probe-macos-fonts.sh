#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -eq 0 ]]; then
  fonts=(
    "STIX Two Text"
    "STIX Two Math"
    "Songti SC"
    "STSong"
    "Songti TC"
    "Heiti SC"
    "Hiragino Sans GB"
    "IBM Plex Mono"
    "Source Han Serif VF"
    "Source Han Serif SC VF"
  )
else
  fonts=("$@")
fi

echo "== Commands =="
for cmd in fc-match luaotfload-tool Rscript xelatex lualatex quarto find; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "%-16s %s\n" "$cmd" "$(command -v "$cmd")"
  else
    printf "%-16s MISSING\n" "$cmd"
  fi
done

echo
echo "== macOS font file hints =="
font_dirs=(
  "$HOME/Library/Fonts"
  "/Library/Fonts"
  "/System/Library/Fonts"
  "/System/Library/Fonts/Supplemental"
)

for font in "${fonts[@]}"; do
  echo "-- ${font}"
  compact="${font//[[:space:]]/}"
  for dir in "${font_dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    find "$dir" -maxdepth 1 -type f \( -iname "*${font}*" -o -iname "*${compact}*" \) -print 2>/dev/null || true
  done
done

echo
echo "== fontconfig =="
for font in "${fonts[@]}"; do
  echo "-- ${font}"
  if command -v fc-match >/dev/null 2>&1; then
    match="$(fc-match "$font" || true)"
    echo "$match"
    if [[ "$font" == *"VF"* || "$match" == *"VF"* ]]; then
      echo "WARN: variable/VF font candidate; avoid as a XeLaTeX PDF font unless a smoke render proves it."
    fi
    if [[ "$match" == *".ttc"* || "$match" == *".otc"* ]]; then
      echo "NOTE: font collection candidate; XeLaTeX may need a verified family name or FontIndex."
    fi
    if [[ "$match" == *".woff"* || "$match" == *".woff2"* ]]; then
      echo "WARN: web font candidate; use for HTML, not XeLaTeX PDF."
    fi
    fc-match -v "$font" | rg 'file:|index:|fontformat:|postscriptname:|variable:|namedinstance:' || true
  else
    echo "fc-match missing"
  fi
done

echo
echo "== luaotfload =="
for font in "${fonts[@]}"; do
  echo "-- ${font}"
  if command -v luaotfload-tool >/dev/null 2>&1; then
    luaotfload-tool --find="$font" || true
  else
    echo "luaotfload-tool missing"
  fi
done

echo
echo "== R systemfonts =="
if command -v Rscript >/dev/null 2>&1; then
  Rscript -e 'fonts <- commandArgs(TRUE); if (!requireNamespace("systemfonts", quietly = TRUE)) { cat("systemfonts is not installed\n"); quit(status = 0) }; matched <- systemfonts::match_fonts(fonts); print(matched); fallback <- fonts[grepl("/Helvetica[.]ttc$", matched$path)]; if (length(fallback)) cat("\nWARN: likely R-side fallback to Helvetica for:", paste(fallback, collapse = ", "), "\n")' "${fonts[@]}"
else
  echo "Rscript missing"
fi
