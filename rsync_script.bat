@echo off

set WSLPATH=/mnt/c/Backups/GTNH
set RSYNCLOG=%WSLPATH%/rsync_log.txt

WSL -d Ubuntu -e rm %RSYNCLOG%
WSL -d Ubuntu -e rsync -auv --delete --log-file=%RSYNCLOG% oracle:gtnh/backups/ /mnt/c/Backups/GTNH/rsync
