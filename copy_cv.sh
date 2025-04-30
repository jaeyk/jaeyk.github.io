#!/bin/sh  # Specifies that this script should be executed using the shell

# Change to the parent directory
echo "Changing to the parent directory..."
cd .. 
echo "Now in the parent directory."

# Copy the CV file from the Downloads folder to the GitHub.io directory
echo "Copying CV from Downloads to the GitHub.io directory..."
cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ~/Documents/jaeyk.github.io/.
echo "CV successfully copied."

# Change to the GitHub.io directory
echo "Changing to the GitHub.io directory..."
cd ~/Documents/jaeyk.github.io/
echo "Now in the GitHub.io directory."

# **Render your essays before publishing**
echo "Rendering essays..."
cd essays/
quarto render .
cd ..
echo "Essays rendered."

# Publish the Quarto website to GitHub Pages
echo "Publishing the Quarto website to GitHub Pages..."
quarto publish gh-pages --no-prompt  # This will render the site (again) and push to the gh-pages branch

echo "All files copied, essays rendered, website rendered, and changes pushed to GitHub Pages."
