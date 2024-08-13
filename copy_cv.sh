#!/bin/sh

echo "copying CV"

cd .. 
cp ~/Downloads/CV_Jae_Yeon_Kim.pdf ~/Documents/jaeyk/.
cd ~/Documents/jaeyk/
git add .
git commit -m "update CV"
git push

echo "pushing CV done"