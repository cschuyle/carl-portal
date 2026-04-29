#!/bin/sh
# Point this repo at versioned hooks under .githooks/ (run once after clone).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git config core.hooksPath .githooks
echo "core.hooksPath set to .githooks (pre-commit checks cv.html for __BUILD_DATE__)."
