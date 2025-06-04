#!/bin/sh

echo "Switching to the website directory..."
cd ~/Documents/jaeyk.github.io/ || { echo "Directory not found. Aborting."; exit 1; }

echo "Copying CV..."
cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ./CV_Jae_Yeon_Kim.pdf

echo "Compiling SCSS..."
sass styles.scss styles.css

echo "Rendering the Quarto site..."
quarto render

echo "Publishing to GitHub Pages..."
quarto publish gh-pages --no-prompt

echo "Done!"
