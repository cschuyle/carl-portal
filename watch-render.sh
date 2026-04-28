#!/usr/bin/env bash
# Render page.md → page.html (via build.sh), print local URLs, rebuild when inputs change.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SERVE=false
PORT=8765
while [[ $# -gt 0 ]]; do
  case "$1" in
    --serve | -s) SERVE=true; shift ;;
    --port)
      PORT="${2:?--port requires a number}"
      shift 2
      ;;
    --port=*)
      PORT="${1#*=}"
      shift
      ;;
    -h | --help)
      echo "Usage: $0 [--serve|-s] [--port N]"
      echo "  Renders with ./build.sh, prints file:// and optional http:// links, watches inputs."
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

WATCH=(*.md template.html header.html navbar.html footer.html styles.css)

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
  local abs="$ROOT/page.html"
  echo ""
  echo "Rendered:  $abs"
  echo "Local URL: file://$abs"
  if $SERVE; then
    echo "HTTP URL:  http://127.0.0.1:${PORT}/page.html"
  fi
  echo ""
}

collect_watch_files
if [[ ${#WATCH_FILES[@]} -eq 0 ]]; then
  echo "No watched files found yet (${WATCH[*]}). Add at least page.md (and templates) to this directory." >&2
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
