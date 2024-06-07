#!/bin/bash

# 21/10/24 - Auto Restore from OneDrive Script by Jordan
# To be used in conjuction with my backup_to_onedrive.sh script
# Allows you to select which day you want to restore the server to, acting as a rollback.

# Has been written to be flexible, you can either restore everything
# Or select to restore only certain backed up data.

##################################################################

user="root"
password="REDACTED"
host="localhost"
backup_dir="/tmp/pw_backups"
log_file="/root/restore_from_onedrive.log"

##################################################################

# Ensure the backup directory exists
mkdir -p "$backup_dir"

# Function to clean up temporary files
cleanup() {
  echo "$(date): Cleaning up temporary files..."
  rm -f "$backup_dir/$backup_filename"
  rm -f "$backup_dir/$sql_pw_backup_name"
  rm -f "$backup_dir/$sql_forums_backup_name"
  rm -f "$backup_dir/$sql_panel_backup_name"
  rm -f "$backup_dir/backup_list.txt"
  echo "$(date): Cleanup completed."
}

# Trap to call the cleanup function if the script exits or encounters an error
trap cleanup EXIT

# Start logging
exec > >(tee -a "$log_file") 2>&1

echo "$(date): Starting restore process."

# Step 1: Ask for the date and list available backups for that date on OneDrive
echo "Please enter the date of the backup folder you want to restore from (e.g., 2024-10-22):"
read backup_date

onedrive_folder="InfernalOneDrive:automated_backups/$backup_date"

echo "$(date): Fetching available backups from OneDrive folder $onedrive_folder..."
rclone lsf "$onedrive_folder/" >$backup_dir/backup_list.txt &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error fetching backup list from OneDrive for date $backup_date."
  exit 1
fi

cat $backup_dir/backup_list.txt

# Step 2: Download all the files from the selected date folder
echo "$(date): Downloading all files from $onedrive_folder..."

rclone copy "$onedrive_folder/" "$backup_dir/" &>>$log_file

if [ $? -ne 0 ]; then
  echo "$(date): Error downloading files from OneDrive for date $backup_date."
  exit 1
else
  echo "$(date): All files downloaded successfully from $onedrive_folder."
fi

# Identify the SQL and tar.gz files
sql_pw_backup_name=$(ls $backup_dir | grep pw_sql_backup_)
sql_forums_backup_name=$(ls $backup_dir | grep forums_sql_backup_)
sql_panel_backup_name=$(ls $backup_dir | grep user_panel_sql_backup_)
backup_filename=$(ls $backup_dir | grep .tar.gz)

# Step 3: Unpack the tar.gz file (if present)
if [ -n "$backup_filename" ]; then
  echo "$(date): Unpacking the tar.gz file $backup_filename..."
  tar xzvf "$backup_dir/$backup_filename" -C / &>>$log_file

  if [ $? -ne 0 ]; then
    echo "$(date): Error unpacking the tar.gz file."
  else
    echo "$(date): Files unpacked successfully."
  fi
else
  echo "$(date): No tar.gz file found to unpack, skipping file extraction."
fi

# Step 4: Restore the MariaDB databases

# Restore PW Database (if present)
if [ -n "$sql_pw_backup_name" ]; then
  echo "$(date): Restoring PW Database..."
  mariadb -u $user -p$password pw <"$backup_dir/$sql_pw_backup_name"

  if [ $? -ne 0 ]; then
    echo "$(date): Error restoring PW database."
  else
    echo "$(date): PW database restored successfully."
  fi
else
  echo "$(date): PW database backup not found, skipping restoration."
fi

# Restore Forums Database (if present)
if [ -n "$sql_forums_backup_name" ]; then
  echo "$(date): Restoring Forums Database..."
  mariadb -u $user -p$password forums <"$backup_dir/$sql_forums_backup_name"

  if [ $? -ne 0 ]; then
    echo "$(date): Error restoring Forums database."
  else
    echo "$(date): Forums database restored successfully."
  fi
else
  echo "$(date): Forums database backup not found, skipping restoration."
fi

# Restore User Panel Database (if present)
if [ -n "$sql_panel_backup_name" ]; then
  echo "$(date): Restoring User Panel Database..."
  mariadb -u $user -p$password user_panel <"$backup_dir/$sql_panel_backup_name"

  if [ $? -ne 0 ]; then
    echo "$(date): Error restoring User Panel database."
  else
    echo "$(date): User Panel database restored successfully."
  fi
else
  echo "$(date): User Panel database backup not found, skipping restoration."
fi

# The cleanup function is automatically called upon script completion or error due to the `trap` command

echo "$(date): Restore process successfully completed."
