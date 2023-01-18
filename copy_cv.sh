#!/bin/sh

echo "copying CV"

cd .. 
sudo cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ~/Documents/jaeyk.github.io/.
cd ~/Documents/jaeyk.github.io/
git add .
git commit -m "update CV"
git push

echo "pushing CV done"

echo "copying resume"

cd .. 
sudo cp ~/Documents/create_resume/resume_Jae_Yeon_Kim.pdf 
~/Documents/jaeyk.github.io/.
cd ~/Documents/jaeyk.github.io/
git add .
git commit -m "update resume"
git push

echo "pushing resume done"