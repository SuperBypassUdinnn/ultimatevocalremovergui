#!/usr/bin/env bash

# Resolve the absolute canonical path of the script directory, resolving symlinks
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fallback directory if the script was copied (not symlinked) to a global bin directory
REPO_DIR="/home/superbypassudin/.clone/Github/ultimatevocalremovergui"

if [ ! -d "$SCRIPT_DIR/.venv" ] && [ -d "$REPO_DIR/.venv" ]; then
    SCRIPT_DIR="$REPO_DIR"
fi

cd "$SCRIPT_DIR" || exit 1

# Check if the virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment (.venv) not found in '$SCRIPT_DIR'."
    echo "If you copied this script to a global bin directory, please create a symlink instead:"
    echo "  sudo ln -sf $REPO_DIR/run.sh /usr/local/bin/UVR"
    echo "Or run this script directly from the repository directory."
    exit 1
fi

# Run the application using the python virtual environment interpreter
echo "Launching Ultimate Vocal Remover GUI..."
exec .venv/bin/python UVR.py "$@"
