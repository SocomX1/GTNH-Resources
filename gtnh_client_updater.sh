#!/bin/bash

# MAKE SURE YOUR PRISM LAUNCHER IS CLOSED WHILE RUNNING THIS SCRIPT

# Path of the Prism instance you want to clone
SOURCE_INSTANCE='/mnt/c/Users/Socom/AppData/Roaming/PrismLauncher/instances/GT_New_Horizons_2.8.0_Java_17-25-migrated'

# Path of the updated Prism instance this script will create
TARGET_INSTANCE='/mnt/c/Users/Socom/AppData/Roaming/PrismLauncher/instances/GTNH 2.8.3'

# URL from which to download the new client
CLIENT_DOWNLOAD='https://downloads.gtnewhorizons.com/Multi_mc_downloads/GT_New_Horizons_2.8.3_Java_17-25.zip'

# Don't touch
PACK_ARCHIVE="$(basename "$CLIENT_DOWNLOAD")"
PACK_NAME="${PACK_ARCHIVE%_Java_*}"
PACK_NAME="${PACK_NAME//_/ }"
TMPDIR="$(mktemp -d)"

cleanup() {
    local EXIT_CODE=$?

    if (( EXIT_CODE != 0 )); then
        echo "Error code $EXIT_CODE encountered, cleaning up temp files and aborting script!"
        rm -rf "$TMPDIR" "$TARGET_INSTANCE" || true
    else
        echo "Cleaning up temp files..."
        rm -rf "$TMPDIR" || true
        echo "Done! $PACK_NAME is ready to play."
    fi
}
trap cleanup EXIT

if [[ -d "$TARGET_INSTANCE" ]]; then
    echo "$TARGET_INSTANCE already exists, exiting script!"
    exit 1
fi

echo 'Copying client instance...'
cp -r "$SOURCE_INSTANCE" "$TARGET_INSTANCE"
cd "$TARGET_INSTANCE" || exit 1
sed -i "s/^name=.*/name=$PACK_NAME/" instance.cfg # update Prism instance name

echo 'Deleting old data from copied instance...'
cd "$TARGET_INSTANCE" || exit 1
rm -rf libraries patches mmc-pack.json
cd .minecraft || exit 1
rm -rf config serverutilities mods scripts resources

echo 'Downloading new client files...'
cd "$TMPDIR" || exit 1
wget "$CLIENT_DOWNLOAD"

echo 'Extracting new client files...'
unzip -qo "$PACK_ARCHIVE" || {
    echo "Error: failed to unzip $PACK_ARCHIVE. Is unzip installed?"
    exit 1
}

echo 'Copying new client files to instance...'
cd "$PACK_NAME" || exit 1
cp -r libraries patches mmc-pack.json "$TARGET_INSTANCE"
cd .minecraft || exit 1
cp -r config serverutilities mods "$TARGET_INSTANCE/.minecraft" || true # no idea why there are case sensitive directories for some configs, ignoring these errors for now