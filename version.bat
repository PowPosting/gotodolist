@echo off
REM Script untuk automated versioning di Windows
REM Usage: version.bat [major|minor|patch] "Release message"

setlocal enabledelayedexpansion

if "%~2"=="" (
    echo Usage: %0 [major^|minor^|patch] "Release message"
    echo Example: %0 minor "Add new feature"
    exit /b 1
)

set VERSION_TYPE=%1
set MESSAGE=%~2

REM Get current version from git tags
for /f "delims=" %%i in ('git describe --tags --abbrev=0 2^>nul') do set CURRENT_VERSION=%%i
if "!CURRENT_VERSION!"=="" set CURRENT_VERSION=v0.0.0

REM Remove 'v' prefix
set CURRENT_VERSION=!CURRENT_VERSION:~1!

echo Current version: !CURRENT_VERSION!

REM Parse version
for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT_VERSION!") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

REM Increment version
if /i "%VERSION_TYPE%"=="major" (
    set /a MAJOR+=1
    set MINOR=0
    set PATCH=0
) else if /i "%VERSION_TYPE%"=="minor" (
    set /a MINOR+=1
    set PATCH=0
) else if /i "%VERSION_TYPE%"=="patch" (
    set /a PATCH+=1
) else (
    echo Invalid version type. Use: major, minor, or patch
    exit /b 1
)

set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!

echo New version: !NEW_VERSION!
echo.

set /p CONFIRM="Continue? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo Aborted
    exit /b 1
)

REM Update package.json (frontend)
if exist "client\package.json" (
    echo Updating client/package.json...
    powershell -Command "(Get-Content client\package.json) -replace '\"version\": \".*\"', '\"version\": \"!NEW_VERSION!\"' | Set-Content client\package.json"
)

REM Update version.go (backend)
if exist "go-server\version.go" (
    echo Updating go-server/version.go...
    powershell -Command "(Get-Content go-server\version.go) -replace 'const Version = \".*\"', 'const Version = \"!NEW_VERSION!\"' | Set-Content go-server\version.go"
)

REM Commit version changes
git add client\package.json go-server\version.go 2>nul
git commit -m "chore: bump version to !NEW_VERSION!" 2>nul

REM Create tag
set TAG=v!NEW_VERSION!
git tag -a "%TAG%" -m "%MESSAGE%"

echo.
echo Created tag: %TAG%
echo Message: %MESSAGE%
echo.
echo Next steps:
echo   1. Review changes: git log --oneline -5
echo   2. Push commits: git push origin main
echo   3. Push tag: git push origin %TAG%
echo   4. Or push all: git push --follow-tags
echo.
echo Done!

pause
