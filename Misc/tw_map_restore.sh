#!/bin/bash

# 15/09/24 - Jordan TW Map Rollback/Reset Script
# Wipe the Territory War map in the game perfect world
# Takes a tar file of a TW map database and restores the current database
# Back to that point in time, effectively rolling back the TW map

# Check if backup file name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file-name>"
  exit 1
fi

# Backup file to restore (passed as argument)
backup_file="$1"

# Check if the specified backup file exists
if [ ! -f "$backup_file" ]; then
  echo "Error: Backup file '$backup_file' does not exist. Please provide a valid backup file."
  exit 1
fi

# Extract the sequence of digits from the backup file name
backup_seq=$(echo "$backup_file" | grep -oP '\d{2}-\d{2}-\d{2}-\d{2}-\d{2}')

# MariaDB Info
user="root"
password="***********"
host="localhost"
db_name="pw"

# Auto Backup Folder Location
backup_path="/home/auto_backup"

# Specific files to restore
files_to_restore=(
  "dbhomewdb/dbdata/city"
)

# Directory to extract backup temporarily
restore_tmp="/home/auto_backup/unpack"

# Extract the tar file to the temporary directory
mkdir -p $restore_tmp
tar -xvf $backup_path/$backup_file -C $restore_tmp

# Construct the path to the extracted db_backup.sql file
extracted_dir="$restore_tmp/tmp/$backup_seq"

# Restore specific files
for file_path in "${files_to_restore[@]}"; do
  src_file="$extracted_dir/$file_path"
  dest_file="/home/gamedbd/$file_path"

  # Log the source and destination files
  echo "SRC File: $src_file"
  echo "DST File: $dest_file"

  # Check if the source file exists
  if [ ! -f "$src_file" ]; then
    echo "Error: Source file $src_file not found."
    exit 1
  fi

  # Delete the existing file if it exists
  rm -f "$dest_file"

  # Copy the file from the backup
  cp -f "$src_file" "$dest_file"
done

# Clean up temporary directory
rm -R $restore_tmp

# End of script
