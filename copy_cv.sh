#!/bin/sh

echo "Changing to the parent directory..."
cd ..

echo "Copying CV..."
cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ~/Documents/jaeyk.github.io/.

echo "Switching to the website directory..."
cd ~/Documents/jaeyk.github.io/

echo "Compiling SCSS..."
sass styles.scss styles.css

echo "Rendering the Quarto site..."
quarto render

echo "Publishing to GitHub Pages..."
quarto publish gh-pages --no-prompt

echo "Done!"
