!/bin/bash

#Backup and backup management script for Nextcloud data and configuration directories

#backup directory and the number of days to keep backups
backup_dir="you-path-here/nextcloud_backups/"
days_to_keep=5

# Function to prune backups older than a specified number of days
prune_old_backups() {
            find "$backup_dir" -maxdepth 1 -type d -name "20*" -ctime +$days_to_keep -exec rm -rf {} \;
    }

    # Prune old backups and check if it runs successfully
    if prune_old_backups; then
                echo "Old backups have been pruned."
        else
                    echo "Error: Failed to prune old backups."
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
appdata_source="your-path-here/nextcloud/appdata/"
data_source="you-path-here/nextcloud/data/"

# Use rsync to backup the appdata folder
rsync -av "$appdata_source" "$backup_dir/appdata/"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup appdata folder."
                exit 1
fi

# Use rsync to backup the data folder
rsync -av "$data_source" "$backup_dir/data/"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup data folder."
                exit 1
fi

# Backup the database using mysqldump
docker exec -t your-mysql mysqldump -u root -pPasswordHere NameofDatabase > "$backup_dir/nextcloud.sql"
if [ $? -ne 0 ]; then
            echo "Error: Failed to backup the database."
                exit 1
fi

# Disable maintenance mode
docker exec -t nextcloud occ maintenance:mode --off

echo "Backup completed successfully. Files and database are stored in $backup_dir."


# Send an email notification that backup completed successfully

if [ $? -eq 0 ]; then

        echo "Nextcloud backup to Synology completed successfully on $(hostname)" | mail -s "Success Notification" -a "From: your-email@example.com" your-email@example.com
                else
        echo "Your script backup script for Nextcloud encountered an error on $(hostname)" | mail -s "Error Notification" -a "From: your-email@example.com" your-email@example.com

fi
