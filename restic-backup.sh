#!/bin/bash

# Call this script like this while logged in
# resctic-backup.sh "/directories/to/backup /separated/by/space"

# Backup everything to restic server 01:00
#00 01 * * * BASH_ENV=~/.bashrc bash -l -c '~/scripts/restic-backup.sh "/directories/to/backup /separated/by/space" 2>&1 | logger -t restic-backup'

# Restic conf
#export RESTIC_REPOSITORY="rest:https://user:pass@host.domain.tld"
#export RESTIC_REPOSITORY="/path/to/restic/repo"
#export RESTIC_PASSWORD="repository-pass"

# Static configuration
RESTIC=/usr/bin/restic
BACKUP_DIRECTORIES=$1
LOGFILE=/home/holvi/logs/restic.log

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
if $RESTIC -v backup $BACKUP_DIRECTORIES; then
  # Remove snapshots according to policy
  $RESTIC forget \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 6

  # Remove unneeded data from the repository
  $RESTIC prune

  # Check the repository for errors
  $RESTIC check

  notify "Restic backup succesfull" "Succesfull backup of $BACKUP_DIRECTORIES"
else
  notify "Restic backup broken" "Broken backup of $BACKUP_DIRECTORIES"
fi
