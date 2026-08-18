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
REM CONFIGURATION
REM ============================================================

cd /d "%~dp0"

set "GITHUB_REPO=OmegaSigmaDelta/Sierra-Tango-Kasper-Echo"

set "GODOT_EXE=D:\SteamLibrary\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe"

set "GODOT_PRESET=Windows"

set "GAME_NAME=Ram"

set "BUILD_DIR=D:\RamReleases"

set "GIT_BRANCH=main"

set "MAX_RETRIES=3"

set "RETRY_DELAY=5"


REM ============================================================
REM VERIFY GODOT PROJECT
REM ============================================================

if not exist "project.godot" (
    echo.
    echo ============================================================
    echo ERROR: project.godot was not found.
    echo ============================================================
    echo.
    echo This script must be placed in the root of the
    echo Godot project.
    echo.
    pause
    exit /b 1
)


REM ============================================================
REM GET DATE / TIME
REM ============================================================

for /f "delims=" %%A in (
    'powershell -NoProfile -Command "Get-Date -Format dd.MM.yyyy-HH:mm"'
) do (
    set "DATE_TIME=%%A"
)


REM ============================================================
REM CREATE GIT-SAFE RELEASE TAG
REM ============================================================

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
echo %CD%

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
echo Enter "skip" to:
echo   - Update Git
echo   - Push Git
echo   - Create and push Git tag
echo   - SKIP the EXE/ZIP build
echo   - SKIP the GitHub release
echo.
echo.

set /p "RELEASE_NOTES=Release notes: "


REM ============================================================
REM CHECK FOR SKIP COMMAND
REM ============================================================

set "SKIP_BUILD=0"

if /I "%RELEASE_NOTES%"=="skip" (
    set "SKIP_BUILD=1"
    set "RELEASE_NOTES=Skipped game archive upload."
)


REM ============================================================
REM DEFAULT RELEASE NOTES
REM ============================================================

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

if "%SKIP_BUILD%"=="1" (
    echo Build/release:
    echo SKIPPED
) else (
    echo Build/release:
    echo ENABLED
)

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
    pause
    exit /b 1
)

if "%SKIP_BUILD%"=="0" (

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

) else (

    echo Git:        OK
    echo GitHub CLI: OK
    echo Godot:      SKIPPED

)

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
    echo.
    echo ============================================================
    echo ERROR: This folder is not a Git repository.
    echo ============================================================
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
    pause
    exit /b 1
)

echo.
echo Main branch successfully pushed.
echo.


REM ============================================================
REM SKIP BUILD / RELEASE
REM ============================================================

if "%SKIP_BUILD%"=="1" goto SKIP_BUILD


REM ============================================================
REM 6. CREATE GIT RELEASE TAG
REM ============================================================

echo [6/10] Creating Git release tag...
echo.

echo Tag:
echo %RELEASE_TAG%
echo.

git rev-parse "%RELEASE_TAG%" >nul 2>&1

if not errorlevel 1 (
    echo ERROR: Tag already exists:
    echo %RELEASE_TAG%
    echo.
    pause
    exit /b 1
)

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
    pause
    exit /b 1
)

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
    echo ERROR: ZIP was not created.
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

echo Description:
echo %DATE_TIME%
echo.
echo %RELEASE_NOTES%

echo.


REM ============================================================
REM CREATE RELEASE NOTES FILE
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
REM SKIP BUILD
REM ============================================================

:SKIP_BUILD

echo.
echo.
echo ============================================================
echo                    BUILD SKIPPED
echo ============================================================
echo.

echo "skip" was entered as the release notes.

echo.

echo Git source:
echo UPDATED

echo.

echo Git push:
echo SUCCESS

echo.

echo EXE export:
echo SKIPPED

echo.

echo ZIP creation:
echo SKIPPED

echo.

echo GitHub release:
echo SKIPPED

echo.

echo No game archive was uploaded.

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