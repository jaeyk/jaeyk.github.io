#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}" || { echo "Directory not found. Aborting."; exit 1; }

CV_TARGET="${SCRIPT_DIR}/CV_Jae_Yeon_Kim.pdf"
CV_SOURCE="${SCRIPT_DIR}/generate_cv/cv_Kim.tex"
COMPILE_SCRIPT="${SCRIPT_DIR}/generate_cv/compile_cv.sh"
FORCE_CV="${1:-}"

NEED_CV_COMPILE=0
if [ ! -f "${CV_TARGET}" ]; then
    NEED_CV_COMPILE=1
    echo "CV target not found at ${CV_TARGET}."
elif [ "${FORCE_CV}" = "--force-cv" ]; then
    NEED_CV_COMPILE=1
    echo "Forcing CV rebuild (--force-cv)."
elif [ -f "${CV_SOURCE}" ] && [ "${CV_SOURCE}" -nt "${CV_TARGET}" ]; then
    NEED_CV_COMPILE=1
    echo "CV source is newer than target; rebuilding CV."
fi

if [ "${NEED_CV_COMPILE}" -eq 1 ]; then
    if [ ! -x "${COMPILE_SCRIPT}" ]; then
        echo "Compile script not found or not executable: ${COMPILE_SCRIPT}. Aborting."
        exit 1
    fi
    echo "Running ${COMPILE_SCRIPT} to generate CV..."
    UPDATE_SITE_SKIP_RECURSE=1 UPDATE_SITE_SKIP_GIT=1 "${COMPILE_SCRIPT}"
fi

# Regenerate map assets used in community page if scripts exist
if [ -f ./community_building/coauthor_map.R ] && [ -f ./community_building/partner_map.R ]; then
    echo "Updating map assets..."
    Rscript ./community_building/coauthor_map.R
    Rscript ./community_building/partner_map.R
fi

# Remove scheduled markers for events whose dates have already passed
echo "Updating expired scheduled event markers..."
python3 ./scripts/update_scheduled_events.py --file ./index.qmd

# Regenerate calendar events from index.qmd
echo "Regenerating calendar events..."
Rscript ./generate_calendar.R

# Ensure data source for coauthors page exists before rendering
if [ ! -f ./community_building/coauthors.csv ]; then
    echo "Missing required data file: ./community_building/coauthors.csv. Aborting."
    exit 1
fi

# Render the full site locally so committed docs are ready to deploy
echo "Rendering full site locally..."
quarto render

# Prevent pushing a build with missing static map assets
if [ ! -f ./misc/coauthor_map.png ] || [ ! -f ./misc/partner_map.png ]; then
    echo "Map PNG assets missing in ./misc. Aborting push."
    exit 1
fi

# Stage, commit, and push changes
# Pushes now deploy the committed docs directly; workflow_dispatch remains available for a full rebuild
echo "Committing and pushing changes..."
git add .
git commit -m "Update site $(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"
git push

echo "GitHub Actions will now deploy the prebuilt docs."
echo "Use workflow_dispatch in GitHub Actions when you want a full rebuild on GitHub."
