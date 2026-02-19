#!/bin/sh

set -eu

cd ~/Documents/jaeyk.github.io/ || { echo "Directory not found. Aborting."; exit 1; }

# Only copy CV if it changed
if ! cmp -s ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf 2>/dev/null; then
    echo "Copying CV..."
    cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf
fi

# Regenerate map assets used in community page if scripts exist
if [ -f ./community_building/coauthor_map.R ] && [ -f ./community_building/partner_map.R ]; then
    echo "Updating map assets..."
    Rscript ./community_building/coauthor_map.R
    Rscript ./community_building/partner_map.R
fi

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
