#!/bin/sh

echo "copying CV"

cd .. 
cp Downloads/CV_Jae_Yeon_Kim.pdf jaeyk.github.io/.
cd jaeyk.github.io/
git add .
git commit -m "update CV"
git push

echo "pushing CV done"

echo "copying resume"

cd .. 
cp create_resume/resume_Jae_Yeon_Kim.pdf jaeyk.github.io/.
cd jaeyk.github.io/
git add .
git commit -m "update resume"
git push

echo "pushing resume done"