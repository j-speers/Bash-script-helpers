#!/bin/bash

# Auto Restore Script

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
password="AGjM6w4q4rqUQtj4ZbXf"
host="localhost"
db_name="pw"

# Auto Backup Folder Location
backup_path="/home/auto_backup"

# Folders To Restore
folders[0]="/home/gamedbd/dbhomewdb/"
folders[1]="/home/logs/"
folders[2]="/home/uniquenamed/uname/"

# Directory to extract backup temporarily
restore_tmp="/home/auto_backup/unpack"

# Extract the tar file to the temporary directory
mkdir -p $restore_tmp
tar -xvf $backup_path/$backup_file -C $restore_tmp

# Construct the path to the extracted db_backup.sql file
extracted_dir="$restore_tmp/tmp/$backup_seq"

# Check if the db_backup.sql file exists
if [ ! -f "$extracted_dir/db_backup.sql" ]; then
    echo "Error: db_backup.sql file not found in $extracted_dir."
    exit 1
fi

# Restore MariaDB
echo -e "RUN COMMAND: mariadb -u $user -p$password < $extracted_dir/db_backup.sql"
mariadb -u $user -p$password <"$extracted_dir/db_backup.sql"

# Restore folders
for n in "${folders[@]}"; do
    src_folder="$extracted_dir/$(basename $n)/"
    dest_folder="$n"

    # Log the source and destination folders
    echo "SRC Folder: $src_folder"
    echo "DST Folder: $dest_folder"

    # Check if the source folder exists
    if [ ! -d "$src_folder" ]; then
        echo "Error: Source folder $src_folder not found."
        exit 1
    fi

    # Delete Previously Existing Character Data Folders
    rm -rf "$dest_folder"

    # Paste The Character Data Folders Over From The Backup
    cp -rf "$src_folder" "$dest_folder"
done

# Fix Permissions
chmod -R 777 /home/

# Clean up temporary directory
rm -R $restore_tmp

# End of script
