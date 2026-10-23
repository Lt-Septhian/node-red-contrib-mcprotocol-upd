@echo off
setlocal EnableExtensions

set "PACKAGE_DIR=%~dp0"
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
  exit /b 1
)
where npm >nul 2>&1 || (
  echo Error: npm is not installed or not in PATH.
  exit /b 1
)

for /f "usebackq delims=" %%V in (`node -p "process.versions.node.split('.')[0]"`) do set "NODE_MAJOR=%%V"
if %NODE_MAJOR% LSS 26 (
  for /f "delims=" %%V in ('node --version') do set "NODE_VERSION=%%V"
  echo Error: Node.js 26 or newer is required; found %NODE_VERSION%.
  exit /b 1
)

if not exist "%NODE_RED_DIR%" mkdir "%NODE_RED_DIR%" || exit /b 1
if not exist "%NODE_RED_DIR%\package.json" (
  >"%NODE_RED_DIR%\package.json" echo {"name":"node-red-project","version":"0.0.1","private":true}
)

echo Installing node-red-contrib-mcprotocol from: %PACKAGE_DIR%
echo Node-RED user directory: %NODE_RED_DIR%
call npm install --prefix "%NODE_RED_DIR%" "%PACKAGE_DIR%"
if errorlevel 1 exit /b %errorlevel%

echo.
echo Installation complete. Restart Node-RED, then refresh the editor.
echo Verify with: cd /d "%NODE_RED_DIR%" ^&^& npm list node-red-contrib-mcprotocol
exit /b 0
