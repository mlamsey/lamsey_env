#!/usr/bin/env bash
set -euo pipefail

SRC="/var/lib/snapd/desktop/applications/spotify_spotify.desktop"
DEST_DIR="$HOME/.local/share/applications"
DEST="$DEST_DIR/spotify_spotify.desktop"

if [[ ! -f "$SRC" ]]; then
    echo "Error: Spotify Snap launcher not found at:"
    echo "  $SRC"
    exit 1
fi

mkdir -p "$DEST_DIR"

# Copy the Snap-provided launcher to a user-local override.
cp "$SRC" "$DEST"

# Add --audio-api=pulseaudio to Spotify Exec lines, unless already present.
sed -i '/^Exec=.*spotify/ {
    /--audio-api=pulseaudio/! s|\(spotify\)\(.*\)|\1 --audio-api=pulseaudio\2|
}' "$DEST"

# Refresh desktop launcher metadata if the utility is available.
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DEST_DIR"
fi

echo "Updated Spotify launcher:"
echo "  $DEST"
echo
grep '^Exec=' "$DEST"
