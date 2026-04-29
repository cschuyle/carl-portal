#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

COMMON="--template template.html --include-in-header header.html --include-after-body footer.html --standalone --no-highlight --toc --toc-depth 2 --mathjax"
STRIP_FILTER="$ROOT/filters/strip-cv-detailed.lua"

pandoc index.md -o index.html --include-before-body navbar.html $COMMON

# Human-readable "Month D, YYYY" for cv.md **Updated:** __BUILD_DATE__
BUILD_DATE=$(python3 -c "import datetime; d=datetime.date.today(); print(d.strftime('%B') + ' ' + str(d.day) + ', ' + str(d.year))")

sed "s|__BUILD_DATE__|${BUILD_DATE}|g" cv.md | pandoc -f markdown -o cv.html \
  --include-before-body navbar-cv-abbrev.html $COMMON \
  --lua-filter "$STRIP_FILTER" \
  -M cv_title_nav=true -M abbreviated_cv=true

sed "s|__BUILD_DATE__|${BUILD_DATE}|g" cv.md | pandoc -f markdown -o full-cv.html \
  --include-before-body navbar-cv-full.html $COMMON \
  -M cv_title_nav=true
