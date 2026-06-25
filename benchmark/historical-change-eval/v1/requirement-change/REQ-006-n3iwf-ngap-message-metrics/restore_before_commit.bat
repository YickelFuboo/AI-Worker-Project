@echo off
setlocal EnableExtensions

set "CASE_DIR=%~dp0"
for %%I in ("%CASE_DIR%..\..\..\..") do set "PROJECT_ROOT=%%~fI"
set "REPO=%PROJECT_ROOT%\repos\n3iwf"
set "BEFORE_COMMIT=d2d8ff6ee424f234c06096d4c191d86af3ada392"
set "CASE_ID=REQ-006"
set "CASE_TITLE=N3IWF 增加 NGAP 消息指标采集"

if not exist "%REPO%\.git" (
  echo [ERROR] Repository not found: %REPO%
  echo This script expects the benchmark directory to keep its relative position to repos\.
  exit /b 1
)

echo Case: %CASE_ID% - %CASE_TITLE%
echo Repository: %REPO%
echo Target commit: %BEFORE_COMMIT%
echo.

pushd "%REPO%" >nul || exit /b 1

for /f "delims=" %%S in ('git status --porcelain') do (
  echo [ERROR] Repository has uncommitted changes. Commit, stash, or discard them before restoring.
  echo.
  git status --short
  popd >nul
  exit /b 1
)

git checkout "%BEFORE_COMMIT%"
if errorlevel 1 (
  echo [ERROR] git checkout failed.
  popd >nul
  exit /b 1
)

echo.
echo [OK] Repository restored to benchmark starting state.
git --no-pager log -1 --oneline
popd >nul
endlocal
