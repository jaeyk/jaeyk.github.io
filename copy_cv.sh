#!/bin/sh

cd ~/Documents/jaeyk.github.io/ || { echo "Directory not found. Aborting."; exit 1; }

# Only copy CV if it changed
if ! cmp -s ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf 2>/dev/null; then
    echo "Copying CV..."
    cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf
fi

# Only compile SCSS if source is newer than output
if [ styles.scss -nt styles.css ]; then
    echo "Compiling SCSS..."
    sass styles.scss styles.css
fi

# Render the site
echo "Rendering site..."
quarto render

# Stage, commit, and push changes
echo "Committing and pushing changes..."
git add .
git commit -m "Update site $(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"
git push

echo "Done!"
