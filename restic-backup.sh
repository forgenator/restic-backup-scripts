#!/bin/bash

# Call this script like this
# resctic-backup.sh "tag" "directory_to_backup"

# Run cron every midnight
# 0 0 * * * /path/to/restic-backup.sh "tag" "directory_to_backup"

# Static configuration
RESTIC=/usr/bin/restic
CONFIG=/home/$USER/.config/restic/env.conf
LOGFILE=/home/$USER/restic.log
TAG=$1
BACKUP_DIRECTORY=$2

# Get the environment also in this file, in case it's not read properly
. $CONFIG

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
if $RESTIC backup \
            --tag $TAG \ # Tag to apply to the backup
            $BACKUP_DIRECTORY \ # Directory to backup
            >> $LOGFILE 2>&1; 
then
  echo "$TIMESTAMP Restic backup succesfull" >> $LOGFILE
  notify "Restic backup succesfull" "Succesfull backup of $BACKUP_DIRECTORY" 
else
  echo "$TIMESTAMP Restic backup went wrong" >> $LOGFILE
  notify "Restic backup broken" "Backup of $BACKUP_DIRECTORY didn't went trough." 
fi
          

# Remove snapshots according to policy
$RESTIC forget \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 7

# Remove unneeded data from the repository
$RESTIC prune

# Check the repository for errors
$RESTIC check
