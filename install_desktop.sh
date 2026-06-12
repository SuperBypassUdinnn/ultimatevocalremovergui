#!/usr/bin/env bash

# Resolve the absolute path of this repository
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Paths for the executable and icon
RUN_SCRIPT="$REPO_DIR/UVR"
ICON_PATH="$REPO_DIR/gui_data/img/GUI-Icon.png"

# Target directory for user-specific desktop entries
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

DESKTOP_FILE="$DESKTOP_DIR/ultimate-vocal-remover.desktop"

# Ensure UVR script is executable
chmod +x "$RUN_SCRIPT"

# Write the .desktop file
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Ultimate Vocal Remover (UVR)
Comment=GUI for Ultimate Vocal Remover (UVR)
Exec="$RUN_SCRIPT"
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=AudioVideo;Audio;AudioVideoEditing;
Keywords=UVR;vocal;remover;separation;music;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

# Refresh desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

echo "Desktop entry installed successfully!"
echo "You can now launch Ultimate Vocal Remover from your applications menu or find the file at:"
echo "  $DESKTOP_FILE"
echo ""

# Copy script to /usr/local/bin
echo "Installing UVR command globally to /usr/local/bin..."
if sudo cp "$RUN_SCRIPT" /usr/local/bin/UVR && sudo chmod +x /usr/local/bin/UVR; then
    echo "Global command installed successfully! You can now run 'UVR' from any terminal."
else
    echo "Warning: Could not install global command to /usr/local/bin."
fi
