#!/bin/sh

cd .. 
cp Downloads/CV_Jae_Yeon_Kim.pdf jaeyk.github.io/.
cd jaeyk.github.io/
git add .
git commit -m "update CV"
git push