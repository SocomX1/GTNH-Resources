#!/bin/bash

# Path of the currently installed GTNH server
SERVER_PATH="/home/opc/gtnh"

# URL from which to download the new GTNH server archive
SERVER_DOWNLOAD_URL="https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.8.4_Server_Java_17-25.zip"

# Path where the backup of the currently installed GTNH server will be created
BACKUP_ARCHIVE="$SERVER_PATH/../gtnh_backup_$(date +%Y-%m-%d-%H%M%S).tar.gz"

# Don't touch
PACK_ARCHIVE="$(basename "$SERVER_DOWNLOAD_URL")"
PACK_NAME="${PACK_ARCHIVE%_Java_*}"
PACK_NAME="${PACK_NAME//_/ }"
MAP_PLUGIN_EXISTS=false

TMPDIR="$(mktemp -d)"

cleanup() {
    local EXIT_CODE=$?

    if (( EXIT_CODE != 0 )); then
        echo "Error code $EXIT_CODE encountered, cleaning up temp files..."
        rm -rf "$TMPDIR" || true
        echo "Temp files removed, but the script exited prematurely."
    else
        echo "Cleaning up temp files..."
        rm -rf "$TMPDIR" || true
        echo "Done! $PACK_NAME is ready to play."
    fi

    echo "Remember to download the backup archive from $BACKUP_ARCHIVE!"
    echo "Also, reset the Vis relay :)"
}
trap cleanup EXIT

echo "Creating archive backup of $SERVER_PATH..."
cd "$SERVER_PATH" || exit 1
tar --exclude='backups' --exclude='dynmap' -czf "$BACKUP_ARCHIVE" -C "$(dirname "$SERVER_PATH")" "$(basename "$SERVER_PATH")" || exit 1

echo "Backing up $SERVER_PATH/config/JourneyMapServer directory..."
cp -r "$SERVER_PATH/config/JourneyMapServer" "$TMPDIR" || exit 1

echo "Backing up Dynmap plugin, if it exists..."
cd "$SERVER_PATH/mods" || exit 1
shopt -s nullglob # ensure file search expands to nothing if no matches
MAP_FILES=( *gtnh-web-map* )
if (( ${#MAP_FILES[@]} > 0 )); then
    MAP_PLUGIN_EXISTS=true
    MAP_PLUGIN=${MAP_FILES[0]}
    echo "Dynmap plugin found: $MAP_PLUGIN"
    cp "$MAP_PLUGIN" "$TMPDIR"
else
    echo "No Dynmap plugin found, proceeding..."
fi
shopt -u nullglob

echo "Downloading new server archive..."
cd "$TMPDIR" || exit 1
wget "$SERVER_DOWNLOAD_URL" || exit 1

echo "Extracting new server files..."
unzip -qo "$PACK_ARCHIVE" || {
    echo "Error: failed to unzip $PACK_ARCHIVE. Is unzip installed?"
    exit 1
}

echo "Deleting old server files..."
cd "$SERVER_PATH" || exit 1
rm -rf config libraries mods resources scripts 'lwjgl3ify-forgePatches.jar' 'java9args.txt' # resources and scripts should only exist in older server versions, no need to copy them over

echo "Copying new server files to $SERVER_PATH..."
cd "$TMPDIR" || exit 1
cp -r config libraries mods 'lwjgl3ify-forgePatches.jar' 'java9args.txt' "$SERVER_PATH"

echo "Copying saved JourneyMapServer config files to $SERVER_PATH/config..."
cd "$TMPDIR" || exit 1
cp -r "JourneyMapServer" "$SERVER_PATH/config"

if [[ $MAP_PLUGIN_EXISTS == true ]]; then
    echo "Copying saved $MAP_PLUGIN plugin to $SERVER_PATH/mods..."
    cd "$TMPDIR" || exit 1
    cp "$MAP_PLUGIN" "$SERVER_PATH/mods"
fi