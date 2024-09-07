#!/bin/bash

# Call this script like this
# resctic-backup.sh "directory_to_backup"

# Backup restic to dropbox
#00 03 * * * BASH_ENV=~/.bashrc bash -l -c '~/scripts/rclone-backup.sh "/path/to/restic-repository" "dropbox:/restic-backups" 2>&1 | logger -t rclone-backup'

# Static configuration
RCLONE=/usr/bin/rclone
BACKUP_DIRECTORY=$1
DESTINATION_DIRECTORY=$2

# Gotify conf
GOTIFY_URL="https://host.domain.tld"
GOTIFY_TOKEN="token"

# Gotify notification
notify()
{
  curl -X POST -s \
    -F "title=${1}" \
    -F "message=${2}" \
    -F "priority=5" \
    "${GOTIFY_URL}/message?token=${GOTIFY_TOKEN}"
}

# Run backup
if $RCLONE -v sync --delete-after $BACKUP_DIRECTORY $DESTINATION_DIRECTORY; then
  notify "Rclone backup succesfull" "Succesfull backup of $BACKUP_DIRECTORY"
else
  notify "Rclone backup broken" "Backup of $BACKUP_DIRECTORY didn't went trough."
fi
