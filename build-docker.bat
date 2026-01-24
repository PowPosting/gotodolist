@echo off
REM Script untuk build Docker images dengan versioning otomatis
REM Usage: build-docker.bat [version]
REM Example: build-docker.bat 1.0.0
REM         atau build-docker.bat (akan otomatis ambil dari git tag)

setlocal enabledelayedexpansion

REM Get version
if "%~1"=="" (
    REM Coba ambil dari git tag
    for /f "delims=" %%i in ('git describe --tags --abbrev=0 2^>nul') do set VERSION=%%i
    if "!VERSION!"=="" (
        REM Jika tidak ada git tag, gunakan default
        set VERSION=v1.0.0
    )
    REM Remove 'v' prefix jika ada
    if "!VERSION:~0,1!"=="v" set VERSION=!VERSION:~1!
) else (
    set VERSION=%~1
    REM Remove 'v' prefix jika ada
    if "!VERSION:~0,1!"=="v" set VERSION=!VERSION:~1!
)

echo ========================================
echo Building Docker Images
echo Version: !VERSION!
echo ========================================
echo.

REM Build Go Server
echo [1/2] Building Go Server...
docker build -t go-to-do-server:!VERSION! -t go-to-do-server:latest -f go-server/Dockerfile ./go-server
if errorlevel 1 (
    echo ERROR: Failed to build go-server
    exit /b 1
)
echo ✓ Go Server built successfully
echo.

REM Build React Client
echo [2/2] Building React Client...
docker build -t go-to-do-client:!VERSION! -t go-to-do-client:latest -f client/Dockerfile ./client
if errorlevel 1 (
    echo ERROR: Failed to build react-client
    exit /b 1
)
echo ✓ React Client built successfully
echo.

echo ========================================
echo ✓ Build Complete!
echo ========================================
echo.
echo Images created:
echo   - go-to-do-server:!VERSION!
echo   - go-to-do-server:latest
echo   - go-to-do-client:!VERSION!
echo   - go-to-do-client:latest
echo.
echo To view images:
echo   docker images ^| findstr go-to-do
echo.
echo To run with docker-compose:
echo   docker-compose up -d
echo.
echo To push to Docker Hub (optional):
echo   docker tag go-to-do-server:!VERSION! yourusername/go-to-do-server:!VERSION!
echo   docker push yourusername/go-to-do-server:!VERSION!
echo.

endlocal
