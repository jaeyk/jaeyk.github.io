#!/bin/sh

cd ~/Documents/jaeyk.github.io/ || { echo "Directory not found. Aborting."; exit 1; }

# Only copy CV if it changed
if ! cmp -s ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf 2>/dev/null; then
    echo "Copying CV..."
    cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf
fi

# Stage, commit, and push changes
# GitHub Actions will handle SCSS compilation and site rendering
echo "Committing and pushing changes..."
git add .
git commit -m "Update site $(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"
git push

echo "GitHub Actions will now build and deploy the site."
echo "Check status at: https://github.com/jaeyk/jaeyk.github.io/actions"
