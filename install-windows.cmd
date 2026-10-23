@echo off
setlocal EnableExtensions
set "EXIT_CODE=0"

set "PACKAGE_DIR=%~dp0"
if "%PACKAGE_DIR:~-1%"=="\" set "PACKAGE_DIR=%PACKAGE_DIR:~0,-1%"
if "%~1"=="" (
  if defined NODE_RED_HOME (
    set "NODE_RED_DIR=%NODE_RED_HOME%"
  ) else (
    set "NODE_RED_DIR=%USERPROFILE%\.node-red"
  )
) else (
  set "NODE_RED_DIR=%~1"
)

where node >nul 2>&1 || (
  echo Error: Node.js is not installed or not in PATH.
  set "EXIT_CODE=1"
  goto :finish
)
where npm >nul 2>&1 || (
  echo Error: npm is not installed or not in PATH.
  set "EXIT_CODE=1"
  goto :finish
)

for /f "usebackq delims=" %%V in (`node -p "process.versions.node.split('.')[0]"`) do set "NODE_MAJOR=%%V"
if %NODE_MAJOR% LSS 26 (
  for /f "delims=" %%V in ('node --version') do set "NODE_VERSION=%%V"
  echo Error: Node.js 26 or newer is required; found %NODE_VERSION%.
  set "EXIT_CODE=1"
  goto :finish
)

if not exist "%NODE_RED_DIR%" mkdir "%NODE_RED_DIR%"
if errorlevel 1 (
  echo Error: Could not create Node-RED directory: %NODE_RED_DIR%
  set "EXIT_CODE=1"
  goto :finish
)
if not exist "%NODE_RED_DIR%\package.json" (
  >"%NODE_RED_DIR%\package.json" echo {"name":"node-red-project","version":"0.0.1","private":true}
)

echo Installing node-red-contrib-mcprotocol from: %PACKAGE_DIR%
echo Node-RED user directory: %NODE_RED_DIR%
call npm install --prefix "%NODE_RED_DIR%" "%PACKAGE_DIR%"
if errorlevel 1 (
  echo.
  echo Installation failed. Node-RED was not updated.
  set "EXIT_CODE=1"
  goto :finish
)

echo.
echo Installation complete. Restart Node-RED, then refresh the editor.
echo Verify with: cd /d "%NODE_RED_DIR%" ^&^& npm list node-red-contrib-mcprotocol

:finish
echo.
echo Press any key to close this installer...
pause >nul
exit /b %EXIT_CODE%
