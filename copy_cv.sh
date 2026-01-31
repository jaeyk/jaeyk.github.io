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

# quarto publish already renders, so no separate render needed
echo "Publishing to GitHub Pages..."
quarto publish gh-pages --no-prompt

echo "Done!"
