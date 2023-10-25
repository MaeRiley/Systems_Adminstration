#!/bin/bash

#backup directory and the number of days to keep backups
backup_dir="/nextcloud_backups/"
days_to_keep=5

# Function to prune backups older than a specified number of days
# NOTE: This will stop working in 77 years from year 2023 when variable "Y" changes to "21"
prune_old_backups() {
            find "$backup_dir" -maxdepth 1 -type d -name "20*" -ctime +$days_to_keep -exec rm -rf {} \;
    }

    # Prune old backups and check if it runs successfully
    if prune_old_backups; then
                echo "Old backups have been pruned."
        else
                    echo "Error: Failed to prune old backups."
                    echo "Nextcloud failed to prune old backups on $(hostname)" | mail -s "Error Notification" -a "From: example@example.com" example@example.com

                        exit 1
    fi

# NextCloud maintenance mode
docker exec -t nextcloud occ maintenance:mode --on

# Timestamp for the backup directory
timestamp=$(date +"%Y%m%d_%H%M")
backup_dir="$backup_dir$timestamp"

# Create the backup directory
mkdir -p "$backup_dir"
chown mae:mae "$backup_dir"

# Define source directories
appdata_source="/nextcloud/appdata/"
data_source="/nextcloud/data/"

# Use rsync to backup the appdata folder
rsync -av "$appdata_source" "$backup_dir/appdata/"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup appdata folder."
            echo "Nextcloud appdata backup failed on $(hostname)" | mail -s "Error Notification" -a "From: example@example.com" example@example.com
                exit 1
fi

# Use rsync to backup the data folder
rsync -av "$data_source" "$backup_dir/data/"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup data folder."
            echo "Nextcloud data backup failed on $(hostname)" | mail -s "Error Notification" -a "From: example@example.com" example@example.com
                exit 1
fi

# Backup the database using mysqldump
docker exec -t nextmysql mysqldump -u root -pYour-Password-Here Database_Name > "$backup_dir/nextcloud.sql"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup the database."
            echo "Nextcloud database backup failed on $(hostname)" | mail -s "Error Notification" -a "From: example@example.com" example@example.com
                exit 1
fi

# Disable maintenance mode
docker exec -t nextcloud occ maintenance:mode --off

echo "Backup completed successfully. Files and database are stored in $backup_dir."


# Send an email notification that backup completed successfully

if [ $? -eq 0 ]; then

        echo "Nextcloud backup to Synology completed successfully maintenance mode OFF on $(hostname)" | mail -s "Success Notification" -a "From: example@example.com" example@example.com
                else
        echo "Nextcloud backup failed to automatically turn off maintenance mode on $(hostname)" | mail -s "Error Notification" -a "From: example@example.com" example@example.com

fi
