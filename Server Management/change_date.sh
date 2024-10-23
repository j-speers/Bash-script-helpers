#!/bin/bash

# 20/07/24 - GitHub interface script by Jordan
# This acts as a simple interface, allowing our less technically savvy developers to
# change the day/time on the Ubuntu box for various gameplay testing purposes
# They can invoke this script from one our development tools

# Date and time parameter
date_param=$1

# Check if the date parameter is provided
if [ -z "$date_param" ]; then
  echo "Error: No date parameter provided."
  echo "Usage: $0 'YYYY-MM-DD HH:MM'"
  exit 1
fi

# Stop the system
echo "Stopping the system..."
/home/stop.sh
sleep 5
echo -e "=== [STOPPED] System Stopped ==="
echo -e ""

# Set the system date and time
echo "Setting system date and time to $date_param..."
date -s "$date_param"
if [ $? -ne 0 ]; then
  echo "Error: Failed to set the system date."
  exit 1
fi
sleep 2
echo -e "=== [DATE SET] System Date Set ==="
echo -e ""

# Start the system
echo "Starting the system..."
/home/start.sh
sleep 1
echo -e "=== [STARTED] System Started ==="
echo -e ""

echo "System is back online with the new date and time: $date_param"
