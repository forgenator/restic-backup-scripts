#!/bin/bash

# Add these to your .bashrc or similar
# Restic conf
export RESTIC_REPOSITORY="repository-url"
export RESTIC_PASSWORD="password-for-repository"

# Call this script like this
# resctic-backup.sh "tag" "directory_to_backup"

# Run cron every midnight
# 0 0 * * * /path/to/restic-backup.sh "tag" "directory_to_backup"

# Static configuration
RESTIC=/usr/bin/restic
LOGFILE=/home/$USER/restic.log
TAG=$1
BACKUP_DIRECTORY=$2

# Gotify conf
GOTIFY_URL="https://host.domain.tld"
GOTIFY_TOKEN="xxxx"

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
if $RESTIC backup --tag $TAG $BACKUP_DIRECTORY >> $LOGFILE 2>&1; then
  notify "Restic backup succesfull" "Succesfull backup of $BACKUP_DIRECTORY" 
else
  notify "Restic backup broken" "Backup of $BACKUP_DIRECTORY didn't went trough." 
fi

# Remove snapshots according to policy
$RESTIC forget \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 7 \
	    >> $LOGFILE 2>&1

# Remove unneeded data from the repository
$RESTIC prune >> $LOGFILE 2>&1

# Check the repository for errors
$RESTIC check >> $LOGFILE 2>&1
