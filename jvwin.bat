@echo off

REM Get the full directory where this script is located
set script_dir=%~dp0
set script_dir=%script_dir:~0,-1%

REM Trim everything after "\addons" to get the base directory
for /f "tokens=1 delims=\addons" %%a in ("%script_dir%") do (
    set base_dir=%%a
)

REM Construct the addon_path
set addon_path="%script_dir%\run.ijs"

REM Construct the executable path
set executable="%base_dir%\bin\jqt.command"

REM Check if the executable exists
if not exist %executable% (
    echo Error: %executable% not found
    exit /b 1
)

REM Launch the executable, passing in the addon_path
start "" %executable% %addon_path%
