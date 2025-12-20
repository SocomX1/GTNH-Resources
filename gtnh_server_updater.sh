#!/bin/bash

SERVER_PATH="/home/opc/gtnh"

echo "Creating archive backup of $SERVER_PATH..."
cd "$SERVER_PATH" || exit
ARCHIVE_DATE=$(date +%Y-%m-%d-%H%M%S)
tar --exclude='backups' --exclude='dynmap' -czvf "$SERVER_PATH/../gtnh_backup_$ARCHIVE_DATE" "$SERVER_PATH"