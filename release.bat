@echo off
setlocal EnableExtensions

cd /d "%~dp0" || goto :fail_open

set "BUILD_PATH="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$file = Get-ChildItem -Path 'Release' -File -Filter '*.zip' | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1; if ($file) { $file.FullName }"`) do set "BUILD_PATH=%%I"

if not defined BUILD_PATH goto :fail_missing_build

for %%I in ("%BUILD_PATH%") do (
    set "BUILD_NAME=%%~nxI"
    set "BUILD_TIME=%%~tI"
)

echo Latest build: %BUILD_NAME%
echo Modified: %BUILD_TIME%
echo.

for /f "delims=" %%I in ('git branch --show-current') do set "BRANCH_NAME=%%I"
if not defined BRANCH_NAME goto :fail_detached_head

for /f "delims=" %%I in ('git status --porcelain --untracked-files=no') do set "GIT_DIRTY=1"
if defined GIT_DIRTY goto :fail_dirty_git

rem Prevent duplicate release creation while the old tag workflow still exists in HEAD.
git cat-file -e HEAD:.github/workflows/release.yml 2>nul
if not errorlevel 1 goto :fail_old_workflow

set /p "VERSION=Version number (e.g. 1.0.8): "
if not defined VERSION goto :fail_missing_version

set "RELEASE_VERSION=%VERSION%"
set "VERSION_OK="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "$v = $env:RELEASE_VERSION.Trim(); if ($v -match '^\d+\.\d+\.\d+([-.][0-9A-Za-z.-]+)?$') { 'VALID' }"`) do set "VERSION_OK=%%I"
if /I not "%VERSION_OK%"=="VALID" goto :fail_bad_version

set "TAG=v%VERSION%"
git rev-parse "refs/tags/%TAG%" >nul 2>nul
if not errorlevel 1 goto :fail_existing_tag

if /I "%DRY_RUN%"=="1" (
    echo [dry-run] Would push the current commit to origin.
    echo [dry-run] Would create release %TAG% from HEAD and upload "%BUILD_NAME%".
    exit /b 0
)

where gh >nul 2>nul
if errorlevel 1 goto :fail_missing_gh

gh auth status >nul 2>nul
if errorlevel 1 goto :fail_gh_auth

for /f "delims=" %%I in ('git rev-parse HEAD') do set "HEAD_SHA=%%I"

echo Pushing current commit to origin...
git push origin "%BRANCH_NAME%"
if errorlevel 1 goto :fail_push

echo Creating GitHub release %TAG% and uploading "%BUILD_NAME%"...
gh release create "%TAG%" "%BUILD_PATH%" --title "%TAG%" --generate-notes --target "%HEAD_SHA%"
if errorlevel 1 goto :fail_release

git fetch --tags origin >nul 2>nul

:success
echo.
echo Release %TAG% was published successfully.
pause
exit /b 0

:fail_open
echo Failed to open the project folder.
goto :fail

:fail_missing_build
echo No ZIP build was found in the Release folder.
goto :fail

:fail_detached_head
echo Releases must be created from a local branch, not detached HEAD.
goto :fail

:fail_dirty_git
echo Git has uncommitted tracked changes.
echo Commit or stash them before publishing so the tag matches the build.
goto :fail

:fail_old_workflow
echo The old tag-based GitHub Actions release workflow is still present in HEAD.
echo Commit the workflow removal before running this script, or GitHub may race the local release upload.
goto :fail

:fail_missing_version
echo Version number is required.
goto :fail

:fail_bad_version
echo Version must look like 1.0.8 or 1.0.8-beta.1
goto :fail

:fail_existing_tag
echo Tag %TAG% already exists locally.
goto :fail

:fail_missing_gh
echo GitHub CLI ^(gh^) is required for publishing releases.
echo Install it from https://cli.github.com/ and run "gh auth login", then try again.
goto :fail

:fail_gh_auth
echo GitHub CLI is installed, but you are not signed in yet.
echo Run "gh auth login" and then try again.
goto :fail

:fail_push
echo Failed to push the current commit to origin.
goto :fail

:fail_release
echo GitHub release creation failed.
goto :fail

:fail
echo.
pause
exit /b 1
