#!/bin/bash

# Get the directory where this script is located
script_dir="$(dirname "$0")"

# Strip everything after "/addons" and construct the executable path
base_dir="${script_dir%%/addons*}"
executable="$base_dir/bin/jqt.command"

# Construct the addon_path
addon_path="$script_dir/run.ijs"

# Check if the executable exists and is executable
if [ ! -x "$executable" ]; then
  echo "Error: $executable not found or not executable"
  exit 1
fi

# Launch the executable in the background, passing in the addon_path
nohup "$executable" "$addon_path" >/dev/null 2>&1 & disown
