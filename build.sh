#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

COMMON="--template template.html --include-in-header header.html --include-after-body footer.html --standalone --no-highlight --toc --toc-depth 2 --mathjax"

pandoc index.md -o index.html --include-before-body navbar.html $COMMON
pandoc cv.md -o cv.html --include-before-body navbar-cv.html $COMMON
