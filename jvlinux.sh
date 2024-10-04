#!/bin/bash

# Get the directory where this script is located
script_dir="$(dirname "$(readlink -f "$0")")"

# Strip everything after "/addons" to get the base directory
base_dir="${script_dir%%/addons*}"

# Construct the addon_path
addon_path="$script_dir/run.ijs"

# Construct the executable path
executable="$base_dir/bin/jqt.command"

# Check if the executable exists and is executable
if [ ! -x "$executable" ]; then
  echo "Error: $executable not found or not executable"
  exit 1
fi

# Launch the executable in the background, passing in the addon_path
nohup "$executable" "$addon_path" >/dev/null 2>&1 & disown
