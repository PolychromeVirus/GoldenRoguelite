@echo off
set /p VERSION="Version number (e.g. 1.0.0): "
git add Release/GoldenRoguelite.zip
git commit -m "v%VERSION%"
git tag v%VERSION%
git push
git push --tags
echo Done! Release v%VERSION% is on its way to GitHub.
pause
