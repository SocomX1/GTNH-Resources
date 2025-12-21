#!/bin/bash

SERVER_PATH="/home/opc/gtnh"
TMPDIR="$(mktemp -d)"

cleanup() {
    echo "Deleting temp files..."
    rm -rf "$TMPDIR"
    echo "Done!"
}
trap cleanup EXIT

echo "Creating archive backup of $SERVER_PATH..."
cd "$SERVER_PATH" || exit
ARCHIVE_DATE=$(date +%Y-%m-%d-%H%M%S)
tar --exclude='backups' --exclude='dynmap' -czvf "$SERVER_PATH/../gtnh_backup_$ARCHIVE_DATE.tar.gz" "$SERVER_PATH"

echo "Backing up $SERVER_PATH/config/JourneyMapServer directory..."
cp -r "$SERVER_PATH/config/JourneyMapServer" "$TMPDIR"

echo "Deleting old server files..."
cd "$SERVER_PATH" || exit
