#!/bin/sh  # Specifies that this script should be executed using the shell

# Change to the parent directory
echo "Changing to the parent directory..."
cd .. 
echo "Now in the parent directory."

# Copy the CV file from the Downloads folder to the GitHub.io directory
# NOTE: Change the file paths below to match your own system's file structure.
# Replace ~/Downloads/CV_Jae_Yeon_Kim.pdf with the actual path to your CV file
# Replace ~/Documents/jaeyk.github.io/ with the actual path to your GitHub.io directory

echo "Copying CV from Downloads to the GitHub.io directory..."
cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ~/Documents/jaeyk.github.io/.
echo "CV successfully copied."

# Change to the GitHub.io directory
# NOTE: Replace ~/Documents/jaeyk.github.io/ with the actual path to your GitHub.io directory

echo "Changing to the GitHub.io directory..."
cd ~/Documents/jaeyk.github.io/
echo "Now in the GitHub.io directory."

# Render and publish the Quarto website to the gh-pages branch
# NOTE: Ensure that Quarto is set up in your directory and the path to the repository is correct
echo "Publishing the Quarto website to GitHub Pages..."
quarto publish gh-pages  # This will render the site and push to the gh-pages branch

# Check for changes, commit, and push to GitHub (just in case there are local changes)
echo "Checking for changes in the repository..."
git add .  # Add all changes
git commit -m "Updated CV"  # Commit changes with a message

# Push changes to the GitHub repository (in case any manual changes need to be pushed)
echo "Pushing changes to GitHub..."
git push origin main  # Push to the 'main' branch (change if your branch is different)

echo "CV copying process complete, website rendered, and changes pushed to GitHub Pages."