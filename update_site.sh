#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}" || { echo "Directory not found. Aborting."; exit 1; }

CV_TARGET="${SCRIPT_DIR}/CV_Jae_Yeon_Kim.pdf"

if [ ! -f "${CV_TARGET}" ]; then
    COMPILE_SCRIPT="${SCRIPT_DIR}/generate_cv/compile_cv.sh"
    echo "CV target not found at ${CV_TARGET}."
    if [ ! -x "${COMPILE_SCRIPT}" ]; then
        echo "Compile script not found or not executable: ${COMPILE_SCRIPT}. Aborting."
        exit 1
    fi
    echo "Running ${COMPILE_SCRIPT} to generate CV..."
    exec "${COMPILE_SCRIPT}"
fi

# Regenerate map assets used in community page if scripts exist
if [ -f ./community_building/coauthor_map.R ] && [ -f ./community_building/partner_map.R ]; then
    echo "Updating map assets..."
    Rscript ./community_building/coauthor_map.R
    Rscript ./community_building/partner_map.R
fi

# Regenerate calendar events from index.qmd
echo "Regenerating calendar events..."
Rscript ./generate_calendar.R

# Render community page so docs and local links stay in sync
echo "Rendering community page..."
quarto render ./community_building/community.qmd

# Prevent pushing a build with missing static map assets
if [ ! -f ./misc/coauthor_map.png ] || [ ! -f ./misc/partner_map.png ]; then
    echo "Map PNG assets missing in ./misc. Aborting push."
    exit 1
fi

# Stage, commit, and push changes
# GitHub Actions will handle SCSS compilation and site rendering
echo "Committing and pushing changes..."
git add .
git commit -m "Update site $(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"
git push

echo "GitHub Actions will now build and deploy the site."
echo "Check status at: https://github.com/jaeyk/jaeyk.github.io/actions"
