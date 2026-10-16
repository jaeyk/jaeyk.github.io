#!/usr/bin/env bash
# Preview the website on your computer.
#
# Usage:
#   ./preview.sh           # live preview; pages refresh as you save files
#   ./preview.sh --built   # preview the finished site exactly as it will be
#                          # published, including site search
#
# Stop the preview with Ctrl+C.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

if ! command -v npm >/dev/null 2>&1; then
    echo "Node.js is not installed. Install it from https://nodejs.org (version 22 or newer), then run this again."
    exit 1
fi

if [ ! -d node_modules ]; then
    echo "First run: installing dependencies (takes a minute)..."
    npm ci
fi

case "${1:-}" in
    --built)
        npm run build
        echo "Opening http://localhost:4321/ ..."
        (sleep 2 && open "http://localhost:4321/" >/dev/null 2>&1 || true) &
        npm run preview
        ;;
    "")
        echo "Opening http://localhost:4321/ (site search only works with ./preview.sh --built)..."
        (sleep 3 && open "http://localhost:4321/" >/dev/null 2>&1 || true) &
        npm run dev
        ;;
    *)
        echo "Unknown option: $1 (use --built or nothing)"
        exit 1
        ;;
esac
