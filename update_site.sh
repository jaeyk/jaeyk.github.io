#!/usr/bin/env bash
# Rebuild generated assets, check that the site builds, then commit and push.
# GitHub Actions (.github/workflows/deploy.yml) builds and publishes the site
# after the push, usually within a couple of minutes.
#
# Usage:
#   ./update_site.sh                 # normal update
#   ./update_site.sh --force-cv      # also recompile the CV even if unchanged
#   ./update_site.sh --skip-maps     # don't rerun the R map scripts
#   ./update_site.sh -m "message"    # custom commit message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

CV_TARGET="public/CV_Jae_Yeon_Kim.pdf"
CV_SOURCE="generate_cv/cv_Kim.tex"
FORCE_CV=0
SKIP_MAPS=0
COMMIT_MSG="Update site $(date '+%Y-%m-%d %H:%M')"

while [ $# -gt 0 ]; do
    case "$1" in
        --force-cv) FORCE_CV=1 ;;
        --skip-maps) SKIP_MAPS=1 ;;
        -m) shift; COMMIT_MSG="$1" ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# 1. CV: recompile when the LaTeX source is newer than the PDF (or when forced).
if [ "${FORCE_CV}" -eq 1 ] || [ ! -f "${CV_TARGET}" ] || [ "${CV_SOURCE}" -nt "${CV_TARGET}" ]; then
    echo "Compiling CV..."
    UPDATE_SITE_SKIP_RECURSE=1 UPDATE_SITE_SKIP_GIT=1 ./generate_cv/compile_cv.sh
else
    echo "CV is up to date."
fi

# 2. Community page maps (written to public/misc/).
if [ "${SKIP_MAPS}" -eq 0 ]; then
    if command -v Rscript >/dev/null 2>&1; then
        echo "Updating map images..."
        Rscript r/coauthor_map.R
        Rscript r/partner_map.R
    else
        echo "Rscript not found; skipping map images (use --skip-maps to silence this)."
    fi
fi

# 3. Make sure the site builds before anything is pushed.
if [ ! -d node_modules ]; then
    echo "Installing dependencies..."
    npm ci
fi
# Talks map: look up coordinates for any new talk cities (only contacts the
# lookup service when there is one). A failed lookup shouldn't block the update;
# that talk just stays off the map until the next run.
npm run --silent places || echo "Couldn't look up new talk places; they'll be retried next time."

echo "Building site..."
npm run build

# 4. Commit and push; GitHub Actions deploys from here.
git add -A
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    git commit -m "${COMMIT_MSG}"
fi
git push
echo "Pushed. GitHub Actions is now deploying the site: https://github.com/jaeyk/jaeyk.github.io/actions"
