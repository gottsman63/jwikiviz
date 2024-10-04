@echo off

REM Get the directory where this script is located
set script_dir=%~dp0
set script_dir=%script_dir:~0,-1%

REM Strip the known substring "addons\gottsman63\jwikiviz\jvwin.bat" from the path to get the base directory
set base_dir=%script_dir:addons\gottsman63\jwikiviz=%

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
