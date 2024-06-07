#!/bin/bash

# 21/10/24 - Auto Backup to OneDrive Script by Jordan
# Saves important areas of my Ubuntu server hosting a game server, Nginx web server and Maria Database.
# Backups are stored externally on OneDrive for disaster recovery purposes.

# Script is called once a day by a cronjob, each days backups are stored in
# a folder on OneDrive in the format yyy-mm-dd

# Plenty of logging and error handling throughout as these backups are critical.

##################################################################

user="root"
password="REDACTED"
host="localhost"
backup_dir="/tmp/pw_backups"
log_file="/root/backup_to_onedrive.log"
onedrive_folder="InfernalOneDrive:automated_backups/$(date +%Y-%m-%d)"

##################################################################

# Ensure the backup directory exists
mkdir -p "$backup_dir"

# Function to clean up temporary files
cleanup() {
  echo "$(date): Cleaning up temporary files..."
  rm -f "$backup_filepath"
  rm -f "/tmp/$backup_pw_sql_name"
  rm -f "/tmp/$backup_forums_sql_name"
  rm -f "/tmp/$backup_panel_sql_name"
  echo "$(date): Cleanup completed."
}

# Trap to call the cleanup function if the script exits or encounters an error
trap cleanup EXIT

# Start logging
exec > >(tee -a "$log_file") 2>&1

echo "$(date): Starting backup process."

# Step 1: Compress important server files
echo "$(date): Compressing server files..."

# Folders to back up
backup_folders=("/home/" "/etc/nginx/" "/usr/share/nginx")
backup_filename="server_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
backup_filepath="$backup_dir/$backup_filename"

# Compress the files
tar czvf "$backup_filepath" "${backup_folders[@]}" &>/dev/null

if [ $? -ne 0 ]; then
  echo "$(date): Error compressing files."
  exit 1
fi

echo "$(date): Compression completed successfully."

# Step 2: Backup MariaDB databases
backup_pw_sql_name="pw_sql_backup_$(date +%Y%m%d_%H%M%S).sql"
backup_forums_sql_name="forums_sql_backup_$(date +%Y%m%d_%H%M%S).sql"
backup_panel_sql_name="user_panel_sql_backup_$(date +%Y%m%d_%H%M%S).sql"

# Backup PW database
echo "$(date): Backing up MariaDB PW Database..."
mariadb-dump -u $user -p$password pw >"/tmp/$backup_pw_sql_name"

if [ $? -ne 0 ]; then
  echo "$(date): Error backing up PW database."
  exit 1
fi

# Backup Forums database
echo "$(date): Backing up MariaDB Forums Database..."
mariadb-dump -u $user -p$password forums >"/tmp/$backup_forums_sql_name"

if [ $? -ne 0 ]; then
  echo "$(date): Error backing up Forums database."
  exit 1
fi

# Backup User Panel database
echo "$(date): Backing up MariaDB User Panel Database..."
mariadb-dump -u $user -p$password user_panel >"/tmp/$backup_panel_sql_name"

if [ $? -ne 0 ]; then
  echo "$(date): Error backing up User Panel database."
  exit 1
fi

echo "$(date): Database backup completed successfully."

# Step 3: Upload to OneDrive
echo "$(date): Uploading backups to OneDrive folder: $onedrive_folder..."

# Create the folder on OneDrive (rclone will create the folder if it doesn't exist)
rclone mkdir "$onedrive_folder" &>>$log_file

# Upload compressed files
echo "$(date): Uploading compressed files..."
rclone copy "$backup_filepath" "$onedrive_folder/" &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error uploading compressed files to OneDrive."
  exit 1
fi

# Upload PW Database backup
echo "$(date): Uploading PW Database backup..."
rclone copy "/tmp/$backup_pw_sql_name" "$onedrive_folder/" &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error uploading PW database backup to OneDrive."
  exit 1
fi

# Upload Forums Database backup
echo "$(date): Uploading Forums Database backup..."
rclone copy "/tmp/$backup_forums_sql_name" "$onedrive_folder/" &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error uploading Forums database backup to OneDrive."
  exit 1
fi

# Upload User Panel Database backup
echo "$(date): Uploading User Panel Database backup..."
rclone copy "/tmp/$backup_panel_sql_name" "$onedrive_folder/" &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error uploading User Panel database backup to OneDrive."
  exit 1
fi

echo "$(date): Files uploaded successfully."

# Step 4: Clear memory cache (optional, but included for consistency)
echo "$(date): Clearing memory cache..."
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

# The cleanup function is automatically called upon script completion or error due to the `trap` command

echo "$(date): Backup successfully completed."
