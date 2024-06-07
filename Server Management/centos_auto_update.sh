#!/bin/bash

# Script by Jordan to Automate Process of Keeping Box Kernals/Services/Programs Updated
# Crontab will call this script every Monday at 9am (GMT -4)
# Box will auto-reboot if major kernal updates were made
# Logs of Auto-Updates and Auto-Reboots will be written to /root/system_update.log

# For Logging Purposes
append_to_log() {
  echo "[ $(date +"%Y-%m-%d %H:%M:%S") ] $1" >>/root/system_update.log
}

linebreak_log() {
  echo -e "\n===========================================\n" >>/root/system_update.log
}

# Command Variables
cmd_chk_update="/bin/dnf check-upgrade"
cmd_update="/bin/dnf upgrade --refresh -y"
cmd_chk_restart="/bin/needs-restarting -r"

append_to_log "Checking For Available Updates..."

$cmd_chk_update
exit_code=$?

# Updates Found
if [ $exit_code -eq 100 ]; then

  append_to_log "Updates Available! Beginning Download And Installation Process Now!"

  $cmd_update
  exit_code=$?

  # Unexpected Error When Downloading/Installing Updates
  if [ $exit_code -ne 0 ]; then
    append_to_log "[ERROR] Something Went Wrong When Running Command: ${cmd_update}"
    append_to_log "[ERROR] Command Error Code: ${exit_code}"
    append_to_log "[ERROR] Auto-Update Script Failed - Exiting."
    linebreak_log
    exit 1
  # Updated Sucessfully
  else
    append_to_log "Updates Have Now Been Downloaded and Installed!"
  fi
# No Updates Found
elif [ $exit_code -eq 0 ]; then
  append_to_log "Looks like the entire system is already up to date!"
  append_to_log "No Updates Downloaded!"
  append_to_log "No Reboot Required!"
  append_to_log "Auto-Update Script Finished Successfully - Exiting."
  linebreak_log
  exit 0
# Unexpected Error When Checking If Updates Available
else
  append_to_log "[ERROR] Something Went Wrong When Running Command: ${cmd_chk_update}"
  append_to_log "[ERROR] Command Error Code: ${exit_code}"
  append_to_log "[ERROR] Auto-Update Script Failed - Exiting."
  linebreak_log
  exit 1
fi

append_to_log "Checking If System Reboot Is Required..."

$cmd_chk_restart
exit_code=$?

# No Restart Required
if [ $exit_code -eq 0 ]; then
  append_to_log "No Reboot Required This Time! =)"
  append_to_log "System Is Now Fully Updated!"
  append_to_log "Auto-Update Script Finished Successfully - Exiting."
  linebreak_log
  exit 0
# Restart Required
elif [ $exit_code -eq 1 ]; then
  append_to_log "Script Has Detected A System Reboot IS Required! *sirens blare* O_O"
  append_to_log "System will be rebooted in 30 seconds!"
  append_to_log "Auto-Update Script Finished Successfully - Exiting."
  linebreak_log

  echo "Warning: System performing scheduled reboot in 30 seconds to apply updates - Save your work!"

  # Shutdown MC Server Here TODO
  # Shutdown IRC and Services Here TODO

  sleep 30
  exit 0
  #systemctl reboot
# Unexpected Error When Checking If Restart Required
else
  append_to_log "[ERROR] Something Went Badly Wrong When Running Command: ${cmd_chk_restart}"
  append_to_log "[ERROR] Command Error Code: ${exit_code}"
  append_to_log "[ERROR] Auto-Update Script Failed - Exiting."
  linebreak_log
  exit 1
fi
