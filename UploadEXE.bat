@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM
REM                    GNoy simulator
REM
REM       AUTOMATIC GIT BACKUP + GODOT BUILD + RELEASE
REM
REM ============================================================


REM ============================================================
REM FORCE SCRIPT TO RUN FROM GODOT PROJECT DIRECTORY
REM ============================================================

cd /d "%~dp0"

if not exist "project.godot" (
    echo.
    echo ============================================================
    echo ERROR: project.godot was not found.
    echo ============================================================
    echo.
    echo This script must be located in the root of your
    echo Godot project.
    echo.
    echo Current directory:
    cd
    echo.
    pause
    exit /b 1
)


REM ============================================================
REM CONFIGURATION
REM ============================================================

set "GITHUB_REPO=OmegaSigmaDelta/Sierra-Tango-Kasper-Echo"

set "GODOT_EXE=D:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe"

set "GODOT_PRESET=Windows"

set "GAME_NAME=Ram"

set "BUILD_DIR=D:\RamReleases"

set "GIT_BRANCH=main"

set "MAX_RETRIES=3"

set "RETRY_DELAY=5"


REM ============================================================
REM GET HUMAN-READABLE DATE / TIME
REM ============================================================

REM Example:
REM 18.08.2026-22:30

for /f "delims=" %%A in (
    'powershell -NoProfile -Command "Get-Date -Format dd.MM.yyyy-HH:mm"'
) do (
    set "DATE_TIME=%%A"
)


REM ============================================================
REM CREATE GIT-SAFE RELEASE TAG
REM ============================================================

REM Example:
REM build-20260818-223045

for /f "delims=" %%A in (
    'powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"'
) do (
    set "RELEASE_TAG=build-%%A"
)


REM ============================================================
REM HEADER
REM ============================================================

echo.
echo ============================================================
echo                 GNoy simulator
echo              AUTOMATIC BUILD SYSTEM
echo ============================================================
echo.

echo Project directory:
cd

echo.

echo Date/time:
echo %DATE_TIME%

echo.

echo Release tag:
echo %RELEASE_TAG%

echo.

echo ============================================================
echo.


REM ============================================================
REM ASK FOR RELEASE NOTES
REM ============================================================

echo Enter release notes for this build.
echo.
echo These notes will appear on the GitHub release.
echo.
echo Example:
echo Added death animation and fixed health system.
echo.

set /p "RELEASE_NOTES=Release notes: "

if "%RELEASE_NOTES%"=="" (
    set "RELEASE_NOTES=No additional notes."
)


REM ============================================================
REM SHOW RELEASE INFORMATION
REM ============================================================

echo.
echo ============================================================
echo Release information
echo ============================================================
echo.

echo Title:
echo Auto release

echo.

echo Date/time:
echo %DATE_TIME%

echo.

echo Notes:
echo %RELEASE_NOTES%

echo.

echo Tag:
echo %RELEASE_TAG%

echo.

echo ============================================================
echo.


REM ============================================================
REM 1. CHECK REQUIRED PROGRAMS
REM ============================================================

echo [1/10] Checking required programs...
echo.

where git >nul 2>&1

if errorlevel 1 (
    echo ERROR: Git was not found.
    echo.
    pause
    exit /b 1
)

where gh >nul 2>&1

if errorlevel 1 (
    echo ERROR: GitHub CLI was not found.
    echo.
    echo Install GitHub CLI and run:
    echo gh auth login
    echo.
    pause
    exit /b 1
)

if not exist "%GODOT_EXE%" (
    echo ERROR: Godot executable was not found:
    echo.
    echo %GODOT_EXE%
    echo.
    pause
    exit /b 1
)

echo Git:        OK
echo GitHub CLI: OK
echo Godot:      OK
echo.


REM ============================================================
REM 2. CHECK GITHUB LOGIN
REM ============================================================

echo [2/10] Checking GitHub authentication...
echo.

gh auth status >nul 2>&1

if errorlevel 1 (
    echo ERROR: GitHub CLI is not logged in.
    echo.
    echo Run:
    echo gh auth login
    echo.
    pause
    exit /b 1
)

echo GitHub authentication: OK
echo.


REM ============================================================
REM 3. CHECK GIT REPOSITORY
REM ============================================================

echo [3/10] Checking Git repository...
echo.

git rev-parse --show-toplevel >nul 2>&1

if errorlevel 1 (
    echo ERROR: This folder is not a Git repository.
    echo.
    echo Expected:
    echo %CD%\.git
    echo.
    echo If this project was already connected to GitHub,
    echo DO NOT run git init yet.
    echo.
    pause
    exit /b 1
)

for /f "delims=" %%A in (
    'git rev-parse --show-toplevel'
) do (
    set "GIT_ROOT=%%A"
)

echo Godot project:
echo %CD%

echo.

echo Git repository:
echo !GIT_ROOT!

echo.

echo Git branch:
for /f "delims=" %%A in (
    'git branch --show-current'
) do (
    set "CURRENT_BRANCH=%%A"
)

echo !CURRENT_BRANCH!

echo.

if not "!CURRENT_BRANCH!"=="%GIT_BRANCH%" (
    echo WARNING:
    echo Current Git branch is "!CURRENT_BRANCH!"
    echo Expected branch is "%GIT_BRANCH%".
    echo.
    echo The script will NOT automatically switch branches.
    echo.
)

echo Git repository: OK
echo.


REM ============================================================
REM 4. GIT BACKUP
REM ============================================================

echo [4/10] Creating Git backup...
echo.

echo Git status BEFORE staging:
echo ------------------------------------------------------------
git status --short
echo ------------------------------------------------------------
echo.

echo Staging all project files...
echo.

git add .

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: git add failed.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo Git status AFTER staging:
echo ------------------------------------------------------------
git status --short
echo ------------------------------------------------------------
echo.

echo Checking staged changes...
echo.

git diff --cached --quiet

if errorlevel 1 (

    echo Changes detected.
    echo.

    echo Creating commit:
    echo Auto release %DATE_TIME%
    echo.

    git commit -m "Auto release %DATE_TIME%"

    if errorlevel 1 (
        echo.
        echo ============================================================
        echo ERROR: Git commit failed.
        echo ============================================================
        echo.
        pause
        exit /b 1
    )

    echo.
    echo Git commit created successfully.

) else (

    echo No source changes detected.
    echo No new Git commit is necessary.

)

echo.


REM ============================================================
REM 5. PUSH MAIN BRANCH
REM ============================================================

echo [5/10] Pushing main branch...
echo.

git push origin %GIT_BRANCH%

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: Git push failed.
    echo ============================================================
    echo.
    echo The GitHub Release will NOT be created.
    echo.
    pause
    exit /b 1
)

echo.
echo Main branch successfully pushed.
echo.


REM ============================================================
REM 6. CREATE GIT RELEASE TAG
REM ============================================================

echo [6/10] Creating Git release tag...
echo.

echo Tag:
echo %RELEASE_TAG%
echo.


REM ------------------------------------------------------------
REM Check whether tag already exists locally
REM ------------------------------------------------------------

git rev-parse "%RELEASE_TAG%" >nul 2>&1

if not errorlevel 1 (
    echo ERROR: Tag already exists locally:
    echo %RELEASE_TAG%
    echo.
    echo This should normally never happen because the tag contains
    echo the current time.
    echo.
    pause
    exit /b 1
)


REM ------------------------------------------------------------
REM Create tag
REM ------------------------------------------------------------

git tag "%RELEASE_TAG%"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: Git could not create the tag.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo Local tag created successfully.
echo.


REM ------------------------------------------------------------
REM Push tag
REM ------------------------------------------------------------

git push origin "%RELEASE_TAG%"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: Git could not push the tag.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo Git tag successfully pushed to GitHub.
echo.


REM ============================================================
REM 7. PREPARE BUILD DIRECTORY
REM ============================================================

echo [7/10] Preparing build directory...
echo.

if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
)

if errorlevel 1 (
    echo.
    echo ERROR: Could not create:
    echo %BUILD_DIR%
    echo.
    pause
    exit /b 1
)


REM ------------------------------------------------------------
REM Delete old build files
REM ------------------------------------------------------------

if exist "%BUILD_DIR%\%GAME_NAME%.exe" (
    del /q "%BUILD_DIR%\%GAME_NAME%.exe"
)

if exist "%BUILD_DIR%\%GAME_NAME%.pck" (
    del /q "%BUILD_DIR%\%GAME_NAME%.pck"
)

if exist "%BUILD_DIR%\%GAME_NAME%.zip" (
    del /q "%BUILD_DIR%\%GAME_NAME%.zip"
)

echo Build directory ready.
echo.


REM ============================================================
REM 8. EXPORT GODOT GAME
REM ============================================================

echo [8/10] Exporting GNoy simulator...
echo.

echo Godot:
echo %GODOT_EXE%

echo.

echo Preset:
echo %GODOT_PRESET%

echo.

echo Output:
echo %BUILD_DIR%\%GAME_NAME%.exe

echo.

"%GODOT_EXE%" ^
    --headless ^
    --path "%CD%" ^
    --export-release "%GODOT_PRESET%" ^
    "%BUILD_DIR%\%GAME_NAME%.exe"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: Godot export failed.
    echo ============================================================
    echo.
    echo Git backup: SUCCESS
    echo Git push:   SUCCESS
    echo Git tag:    SUCCESS
    echo.
    echo The build was NOT released.
    echo.
    pause
    exit /b 1
)


REM ------------------------------------------------------------
REM Verify EXE
REM ------------------------------------------------------------

if not exist "%BUILD_DIR%\%GAME_NAME%.exe" (
    echo.
    echo ============================================================
    echo ERROR: EXE was not created.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo Godot export successful.
echo.


REM ============================================================
REM 9. CREATE ZIP
REM ============================================================

echo [9/10] Creating ZIP archive...
echo.

powershell -NoProfile -Command ^
    "Compress-Archive -Path '%BUILD_DIR%\%GAME_NAME%.*' -DestinationPath '%BUILD_DIR%\%GAME_NAME%.zip' -Force"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: ZIP creation failed.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

if not exist "%BUILD_DIR%\%GAME_NAME%.zip" (
    echo.
    echo ============================================================
    echo ERROR: ZIP was not created.
    echo ============================================================
    echo.
    pause
    exit /b 1
)

echo.
echo ZIP created:
echo %BUILD_DIR%\%GAME_NAME%.zip
echo.


REM ============================================================
REM 10. CREATE GITHUB PRERELEASE
REM ============================================================

echo [10/10] Creating GitHub prerelease...
echo.

echo Tag:
echo %RELEASE_TAG%

echo.

echo Title:
echo Auto release

echo.

echo Release description:
echo %DATE_TIME%
echo.
echo %RELEASE_NOTES%

echo.


REM ============================================================
REM CREATE TEMPORARY RELEASE NOTES FILE
REM ============================================================

set "NOTES_FILE=%TEMP%\gnoy_release_notes.txt"

(
    echo %DATE_TIME%
    echo.
    echo %RELEASE_NOTES%
) > "%NOTES_FILE%"


REM ============================================================
REM RELEASE RETRY LOOP
REM ============================================================

set "RETRY_COUNT=1"

:CREATE_RELEASE

if !RETRY_COUNT! GTR %MAX_RETRIES% goto RELEASE_FAILED

echo.
echo ============================================================
echo Release attempt !RETRY_COUNT! / %MAX_RETRIES%
echo ============================================================
echo.

gh release create "%RELEASE_TAG%" ^
    "%BUILD_DIR%\%GAME_NAME%.zip" ^
    --repo "%GITHUB_REPO%" ^
    --title "Auto release" ^
    --notes-file "%NOTES_FILE%" ^
    --prerelease

if not errorlevel 1 goto SUCCESS


REM ------------------------------------------------------------
REM RELEASE FAILED
REM ------------------------------------------------------------

echo.
echo GitHub release creation failed.
echo.

if !RETRY_COUNT! GEQ %MAX_RETRIES% goto RELEASE_FAILED

echo Waiting %RETRY_DELAY% seconds...
echo.

timeout /t %RETRY_DELAY% /nobreak >nul

set /a RETRY_COUNT+=1

goto CREATE_RELEASE


REM ============================================================
REM SUCCESS
REM ============================================================

:SUCCESS

if exist "%NOTES_FILE%" (
    del /q "%NOTES_FILE%"
)

echo.
echo.
echo ============================================================
echo                         SUCCESS
echo ============================================================
echo.

echo GNoy simulator was successfully released.

echo.

echo Git source:
echo SUCCESS

echo.

echo Git commit:
echo Auto release %DATE_TIME%

echo.

echo Git branch:
echo %GIT_BRANCH%

echo.

echo Git tag:
echo %RELEASE_TAG%

echo.

echo GitHub release:
echo Auto release

echo.

echo Release type:
echo PRERELEASE

echo.

echo Release notes:
echo %RELEASE_NOTES%

echo.

echo Build:
echo %BUILD_DIR%\%GAME_NAME%.zip

echo.

echo GitHub releases:
echo https://github.com/%GITHUB_REPO%/releases

echo.

echo ============================================================
echo.

pause

exit /b 0


REM ============================================================
REM RELEASE FAILURE
REM ============================================================

:RELEASE_FAILED

if exist "%NOTES_FILE%" (
    del /q "%NOTES_FILE%"
)

echo.
echo.
echo ============================================================
echo                    RELEASE FAILED
echo ============================================================
echo.

echo Git backup:       SUCCESS
echo Git push:         SUCCESS
echo Git tag:          SUCCESS
echo Godot export:     SUCCESS
echo ZIP creation:     SUCCESS
echo GitHub release:   FAILED

echo.

echo Tag:
echo %RELEASE_TAG%

echo.

echo ZIP:
echo %BUILD_DIR%\%GAME_NAME%.zip

echo.

echo Attempts:
echo %MAX_RETRIES%

echo.

echo ============================================================
echo.

pause

exit /b 1