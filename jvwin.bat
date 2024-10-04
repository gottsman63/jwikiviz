@echo off

REM Get the directory where this script is located
set script_dir=%~dp0
set script_dir=%script_dir:~0,-1%

REM Find the part of the path before "\addons"
for /f "delims=" %%a in ("%script_dir%") do (
    set "base_dir=%%a"
)

REM Strip off everything after and including "\addons" in the base_dir
set base_dir=%base_dir:\addons=%

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
