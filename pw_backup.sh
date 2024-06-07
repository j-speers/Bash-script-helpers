#!/bin/bash

# Auto Backup Script

# MariaDB Info
user="root"
password="AGjM6w4q4rqUQtj4ZbXf"
host="localhost"
db_name="pw"

# Auto Backup Folder Location
backup_path="/home/auto_backup"

# Folders To Backup
folders[0]="/home/gamedbd/dbhomewdb/"
folders[1]="/home/logs/"
folders[2]="/home/uniquenamed/uname/"

# Backup retention time (in days)
retention_days=60

# Backup MariaDB
date=$(date +"%m-%d-%y-%H-%M")
umask 177
mkdir /tmp/$date
mariadb-dump -u $user -p$password --all-databases >"/tmp/$date/db_backup.sql"
find $backup_path/* -mtime +$retention_days -exec rm {} \;
for n in "${folders[@]}"; do
	cp -r "$n" "/tmp/$date"
done

# Store All Folder + MariaDB Backups in a .tar file
tar -cvvf $backup_path/backup-$date.tar "/tmp/$date"
rm -R "/tmp/$date"
