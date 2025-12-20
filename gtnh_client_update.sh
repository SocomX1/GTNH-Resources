#!/bin/bash

SOURCE_INSTANCE='/mnt/c/Users/Socom/AppData/Roaming/PrismLauncher/instances/GT_New_Horizons_2.8.0_Java_17-25-migrated'
TARGET_INSTANCE='/mnt/c/Users/Socom/AppData/Roaming/PrismLauncher/instances/GT_New_Horizons_2.8.3_Java_17-25-migrated'
CLIENT_DOWNLOAD='https://downloads.gtnewhorizons.com/Multi_mc_downloads/GT_New_Horizons_2.8.3_Java_17-25.zip'

PACK_ARCHIVE="$(basename "$CLIENT_DOWNLOAD")"
PACK_NAME="${PACK_ARCHIVE%_Java_*}"
PACK_NAME="${PACK_NAME//_/ }"

echo 'Copying client instance...'
cp -r $SOURCE_INSTANCE $TARGET_INSTANCE

echo 'Deleting old data from copied instance...'
cd $TARGET_INSTANCE || exit
rm -r libraries patches mmc-pack.json
cd .minecraft || exit
rm -r config serverutilities mods scripts resources

echo 'Downloading new client files...'
cd $TARGET_INSTANCE/.. || exit
wget $CLIENT_DOWNLOAD

echo 'Extracting new client files...'
unzip -o "$PACK_ARCHIVE"

echo 'Copying new client files to instance...'
cd "$PACK_NAME" || exit
cp -r libraries patches mmc-pack.json $TARGET_INSTANCE
cd .minecraft || exit
cp -r config serverutilities mods $TARGET_INSTANCE/.minecraft

echo 'Cleaning up temp files...'
rm -r "$TARGET_INSTANCE/../$PACK_NAME"

echo 'Done!'