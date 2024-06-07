#!/bin/bash

# 13/06/24 - GitHub interface script by Jordan
# Used as part of an automated pipeline, every time one of the developers makes an update using one of
# our game development tools, this script will be called with the name they set themselves in the tool.

# This acts as a simple interface, allowing our less technically savvy developers to commit all
# their changes to GitHub in an easily identifable and organized way,
# without needing to understand the specifics of how it works.

# Name of the Developer
name=$1

# Patch Build

echo "Detected the following modified .data files:"

# Get the list of modified files relative to the home directory
modified_files=$(git diff --name-only HEAD)

# Iterate over the modified files and print their full paths
for file in $modified_files; do
    # Check if the file ends with ".data"
    if [[ $file == *.data ]]; then
        file_path="$(realpath $file)"
        # Print the full path of the file
        echo "- $file_path"
    fi
done
sleep 2

# Github Commit
echo "Committing modified files to Github..."
cd /home/
git add -u
git commit -m "${name} - Triggered Auto Commit @ $(date)"
git push --force origin
sleep 2
echo "Your modifications have been saved on Github, see latest commit at:"
echo "https://github.com/j-speers/infernalpw/commits"
