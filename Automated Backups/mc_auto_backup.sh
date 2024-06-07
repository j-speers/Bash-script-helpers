#!/bin/bash

# 07/08/23 - Script by Jordan to create local backups of a Minecraft server
# Script allows you to configure how many days of backups will be stored before cleanup.
# Put a needless amount of effort into making the output look nice and colourful just for fun!

############### AUTO BACKUP CONFIG START ####################

# Important Config Settings
BACKUP_DAYS=3                 # How many previous days worth of backups should we keep
EXCLUDE=("pve" "test" "plot") # Folder names under ~/servers/ to exclude from backup

# Modify these if you find log/output difficult to read
LOG_MSG_COLOUR="Cyan"
LOG_TIMESTAMP_COLOUR="Yellow"
LOG_MSG_SPACING="1"

# Unlikely these ever need changed
BASE_PATH="/home/minecraft"
BACKUP_PATH="${BASE_PATH}/recent_backups"
SERVERS_PATH="${BASE_PATH}/servers"
LOG="${SERVERS_PATH}/automated_backup.log"
PREFIX="Auto_backup_"
TIMESTAMP=$(date +"%d-%m-%Y_%H-%M-%S")

########### AUTO BACKUP CONFIG CONFIG END ###################

########### FUNCTIONS ####################

calc_script_runtime() {
    local start_time
    local end_time
    local duration

    start_time=$1                                                        # Func 1st Arg
    end_time=$2                                                          # Func 2nd Arg
    duration=$(printf "%.2f\n" "$(echo "$end_time - $start_time" | bc)") # Calc Script Duration

    # Convert Script Duration to Human Readable Output
    if (($(echo "$duration > 60" | bc -l))); then
        duration=$(printf "%.2f\n" $(echo "scale=2; ($end_time - $start_time) / 60" | bc))" Minutes"
    else
        duration=$(printf "%.2f\n" $(echo "$end_time - $start_time" | bc))" Seconds"
    fi

    echo "$duration"
}

# Map human colour values to unicode
colour() {
    local colour_name

    #Colour converted to lower case to make it case-insensitive
    colour_name=${1,,} # Func 1st Arg

    # Colour to Unicode Value Map
    case "$colour_name" in
    black) echo -e "\e[30m" ;;
    red) echo -e "\e[31m" ;;
    green) echo -e "\e[32m" ;;
    yellow) echo -e "\e[33m" ;;
    blue) echo -e "\e[34m" ;;
    magenta) echo -e "\e[35m" ;;
    cyan) echo -e "\e[36m" ;;
    white) echo -e "\e[37m" ;;
    reset) echo -e "\e[0m" ;; # Reset colour
    esac
}

# Function to convert bytes to human readable format
convert_bytes_to_human_readable() {
    local bytes
    bytes=$1 # Func 1st Arg

    # Return bytes as human readable string e.g: 10B/10K/10M/10G
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes} B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo $(((bytes + 1023) / 1024))K
    elif [ "$bytes" -lt 1073741824 ]; then
        echo $(((bytes + 1048575) / 1048576))M
    else
        echo $(((bytes + 1073741823) / 1073741824))G
    fi
}

# O(1) Constant time Algo to parse list of server folders
# not in the exclusion list, so we know what needs backed up.
get_folders_to_backup() {
    # Declare Exclusion list as an Associative Array for better performance
    declare -A EXCLUDE_MAP
    # Fill Associative Array
    for val in "${EXCLUDE[@]}"; do
        EXCLUDE_MAP[$val]=1
    done

    # Initially we find all folders under /servers/
    local parsed_servers=()
    for dir in "${SERVERS_PATH}"/*; do
        if [[ -d $dir ]]; then
            dir_name=$(basename "$dir")
            # Subtract any folders matching EXCLUDE config value
            if [[ -z ${EXCLUDE_MAP[$dir_name]} ]]; then
                parsed_servers+=("$dir_name")
            fi
        fi
    done

    # Return parsed list of folder names we want to back up
    echo "${parsed_servers[@]}"
}

log_header() {
    log_print "=============== >>>>>>>> START <<<<<<<< =================="
}

log_footer() {
    log_print "=============== >>>>>>>> END <<<<<<<< ===================="
}

line_break() {
    local break_count
    count=$1 # Func 1st Arg - How many lines to insert between log messages

    for ((i = 0; i < count; i++)); do
        echo " "
    done
}

# Keep timestamp generation in a func,
# So it updates live each time func is called within script
log_prefix() {
    echo "[$(date +%T)]"
}

# Takes any string and builds it into a formatted message
# Writes formatted message to log and prints to stdout
log_print() {
    local prefix_colour
    local message_colour
    local reset_colour
    local message
    message=$1 # Func 1st Arg

    # Set these values based on Users config for log colours
    prefix_colour=$(colour "$LOG_TIMESTAMP_COLOUR")
    message_colour=$(colour "$LOG_MSG_COLOUR")
    # Wrapper to make resetting colour simpler
    reset_colour=$(colour "reset")

    # Begin Building Formatted String
    log_line="${prefix_colour}"    # Set the colour for the log timestamp
    log_line+="$(log_prefix)"      # Add the timestamp
    log_line+="${reset_colour}"    # Reset the colour
    log_line+=" ${message_colour}" # Set the colour for the log message
    log_line+="$message"           # Add the message
    log_line+="${reset_colour}"    # Reset the colour

    # Write Data to Auto Backup Log file.
    echo "$log_line" >>"${LOG}" | echo $(line_break "2")
    echo $(line_break ${LOG_MSG_SPACING}) >>"${LOG}"

    # Print same Data to Terminal.
    echo "$log_line"
    echo $(line_break "${LOG_MSG_SPACING}")
}

########### BACKUP & COMPRESS ###################
start_time=$(date +%s.%N) # Get Script Start Time

log_header # Print start of log
log_print "Starting Daily Backup And Compress Job..."

# Create SERVERS array, account for file names with spaces
SERVERS=($(get_folders_to_backup))

for server_name in "${SERVERS[@]}"; do
    log_print "Backing up $server_name/ dir..."
    log_print "Backing up & Compressing $server_name/ dir into .tar.gz file to save space..."

    server_folder="${SERVERS_PATH}/${server_name}"
    backup_file_name="${PREFIX}${server_name}_${TIMESTAMP}.tar.gz"
    backup_absolute_path="${BACKUP_PATH}/$backup_file_name"

    # Tar command generates warnings if you don't use a relative path to what you want zipped.
    cd "$server_folder" # Now we can just use relative notation "." to refer to e.g: ~/servers/pve/

    # Gzip contents of current server folder and move compressed file to /recent_backups
    log_print "$(tar -czf "$backup_absolute_path" . | pv -s "$(du -sb "$server_folder" | awk '{print $1}')")"

    log_print "Back up and Compression of [ "$server_name" ] completed!"
    log_print "Compressed File Name: [ "$backup_file_name" ]"
done

log_print "Daily Backup Job has now finished backing up and compressing all servers!"

########### CLEANUP OPERATION ###################

log_print "Starting Daily Backup Folder Cleanup Job..."
log_print "Any Backups older than the currently set storage period of [${BACKUP_DAYS} Days] shall be deleted."

# DEV NOTE: Set at Minutes ago instead of Days for testing purposes, change this from -mmin to -mtime to make it days!
files_to_delete=$(find "${BACKUP_PATH}"/"${PREFIX}"* -type f -mmin +${BACKUP_DAYS})
files_to_delete_count=$(echo "$files_to_delete" | wc -l)

# Do we actually need to clean anything up?
if [ -n "$files_to_delete" ]; then
    log_print "A total of $files_to_delete_count Backups have been marked for Clean Up, they will now be deleted."

    # Delete each old backup
    while IFS= read -r file; do
        deleted_size=$(stat -c %s "$file")
        fmt_deleted_size=$(convert_bytes_to_human_readable "$deleted_size")
        rm -- "$file"
        log_print "Cleaning up $file ... [ Size: $fmt_deleted_size ]"
    done <<<"$files_to_delete"

    log_print "Daily Backup Folder Cleanup Job completed."
# Otherwise, Skip Clean up
else
    log_print "No Backups found older than the current set storage period of ${BACKUP_DAYS} Days! Skipping Cleanup..."
fi

########### AUTO BACKUP STATS ###################

backup_count=0     # Number of Backup Files
backup_size=0      # Bytes
all_backups_size=0 # Bytes

log_print "The following Auto Backups are currently available:"

# Gather and print statistics on current contents of /recent_backups folder
# Now that the script has finished its backup and cleanup operations.
# for file in "${BACKUP_PATH}/${PREFIX}"*; do
# Sort Backups by Date, Print Oldest First and Newest Last
for file in $(ls -rt "${BACKUP_PATH}/${PREFIX}"*); do
    if [ -e "$file" ]; then
        ((backup_count++))
        backup_size=$(stat -c %s "$file")
        fmt_backup_size=$(convert_bytes_to_human_readable "$backup_size")
        all_backups_size=$(($all_backups_size + $backup_size)) # Add size of each backup found to the combined total size
        echo " "
        log_print "============= >>>>> AUTO BACKUP $backup_count <<<<< ================"
        log_print "Path: [$file]"
        log_print "Size: [$fmt_backup_size]"
        log_print "=========================================================="
    else
        log_print "[WARNING] No saved backups found - check auto backup script is correctly configured!"
        log_print "[WARNING] Exiting..."
        exit 1
    fi
done

fmt_all_backups_size=$(convert_bytes_to_human_readable "$all_backups_size")

# Get Script End time
end_time=$(date +%s.%N)

# Calc Runtime
script_runtime=$(calc_script_runtime "$start_time" "$end_time")

# Final Summary To Show User
log_print "###### Summary ######"
log_print "Auto Backup Script Execution Time: [ $script_runtime ]"
log_print "Total Auto Backups Stored: [ $backup_count ]"
log_print "Total Auto Backups Size on Disk: [ $fmt_all_backups_size ]"
log_footer # Print end of log

# Script Ctrl + C'd by User
trap 'echo "$(log_prefix) Auto Backup Script Exiting..."; exit 1' SIGINT
