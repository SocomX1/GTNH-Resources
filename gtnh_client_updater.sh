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

echo 'Copying client instance...'
cp -r "$SOURCE_INSTANCE" "$TARGET_INSTANCE"
cd "$TARGET_INSTANCE" || exit
sed -i "s/^name=.*/name=$PACK_NAME/" instance.cfg

echo 'Deleting old data from copied instance...'
cd "$TARGET_INSTANCE" || exit
rm -r libraries patches mmc-pack.json
cd .minecraft || exit
rm -r config serverutilities mods scripts resources 2> /dev/null # suppress errors as scripts and resources directories only exist in older versions

echo 'Downloading new client files...'
cd "$TARGET_INSTANCE/.." || exit
wget "$CLIENT_DOWNLOAD"

echo 'Extracting new client files...'
unzip -o "$PACK_ARCHIVE"

echo 'Copying new client files to instance...'
cd "$PACK_NAME" || exit
cp -r libraries patches mmc-pack.json "$TARGET_INSTANCE"
cd .minecraft || exit
cp -r config serverutilities mods "$TARGET_INSTANCE/.minecraft"

echo 'Cleaning up temp files...'
cd "$TARGET_INSTANCE/.." || exit
rm -r "$PACK_NAME" "$PACK_ARCHIVE"

echo 'Done!'
