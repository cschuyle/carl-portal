#!/usr/bin/env bash
# Rebuild index.html, cv.html, and full-cv.html via ./build.sh when sources change; print local URLs; optional watch loop.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SERVE=true
PORT=8765
while [[ $# -gt 0 ]]; do
  case "$1" in
    --serve | -s) SERVE=true; shift ;;
    --no-serve | -n) SERVE=false; shift ;;
    --port)
      PORT="${2:?--port requires a number}"
      shift 2
      ;;
    --port=*)
      PORT="${1#*=}"
      shift
      ;;
    -h | --help)
      echo "Usage: $0 [--port N] [--no-serve|-n]"
      echo "  Renders with ./build.sh, starts http://127.0.0.1:\$PORT/ by default (Python http.server), watches inputs."
      echo "  Use --no-serve for file:// links only (no local HTTP server)."
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

WATCH=(*.md template.html header.html navbar.html navbar-cv-abbrev.html navbar-cv-full.html filters/*.lua footer.html styles.css)

collect_watch_files() {
  WATCH_FILES=()
  local f
  for f in "${WATCH[@]}"; do
    [[ -f "$f" ]] && WATCH_FILES+=("$f")
  done
}

SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

build_page() {
  ./build.sh
}

print_links() {
  echo ""
  echo "Rendered:  $ROOT/index.html"
  echo "            $ROOT/cv.html"
  echo "            $ROOT/full-cv.html"
  if $SERVE; then
    echo "Open (HTTP): http://127.0.0.1:${PORT}/index.html"
    echo "             http://127.0.0.1:${PORT}/cv.html"
    echo "             http://127.0.0.1:${PORT}/full-cv.html"
  fi
  echo "file://       file://$ROOT/index.html"
  echo "              file://$ROOT/cv.html"
  echo "              file://$ROOT/full-cv.html"
  echo ""
}

collect_watch_files
if [[ ${#WATCH_FILES[@]} -eq 0 ]]; then
  echo "No watched files found yet (${WATCH[*]}). Add markdown sources and templates to this directory." >&2
  exit 1
fi

if $SERVE; then
  python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$ROOT" &
  SERVER_PID=$!
  sleep 0.2
fi

build_page
print_links

if command -v fswatch &>/dev/null; then
  fswatch -o "${WATCH_FILES[@]}" | while read -r _; do
    build_page && print_links || true
  done
else
  echo "Tip: install fswatch for instant rebuilds (brew install fswatch). Using 1s polling." >&2
  last_sig=$(cat "${WATCH_FILES[@]}" 2>/dev/null | shasum) || last_sig=""
  while true; do
    sleep 1
    sig=$(cat "${WATCH_FILES[@]}" 2>/dev/null | shasum) || sig=""
    if [[ "$sig" != "$last_sig" ]]; then
      last_sig=$sig
      build_page && print_links || true
    fi
  done
fi
