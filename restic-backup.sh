#!/bin/bash

# Static configuration
RESTIC=/usr/bin/restic
CONFIG_DIR=/home/$USER/.config/restic/
LOGFILE=/home/$USER/restic.log

# Get the environment also in this file, in case it's not read properly
. $CONFIG/env.conf

# Gotify notification
notify()
{
        curl -X POST -s \
                -F "title=${1}" \
                -F "message=${2}" \
                -F "priority=5" \
                "${Gotify_URL}/message?token=${Gotify_Token}"

}

# Run backup
if $RESTIC backup \
            --tag $1 \ # Tag to apply to the backup
            $2 \ # Directory to backup
            > /dev/null 2>&1; 
then
  echo "$TIMESTAMP Restic backup succesfull" >> $LOGFILE
  notify "Restic backup succesfull" "Succesfull backup of $2" 
else
  echo "$TIMESTAMP Restic backup went wrong" >> $LOGFILE
  notify "Restic backup broken" "Backup of $2 didn't went trough." 
fi
          

# Remove snapshots according to policy
# If run cron more frequently, might add --keep-hourly 24
$RESTIC forget \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 12 \
            --keep-yearly 7

# Remove unneeded data from the repository
$RESTIC prune

# Check the repository for errors
$RESTIC check

# Done
