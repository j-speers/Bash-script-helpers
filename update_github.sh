#!/bin/bash

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

#echo -e "\nStarting to build patch folder...\n"
#/home/create_patch.sh
#sleep 2

# Github Commit

echo "Committing modified files to Github..."
cd /home/
git add -u
git commit -m "${name} - Triggered Auto Commit @ $(date)"
git push --force origin
sleep 2
echo "Your modifications have been saved on Github, see latest commit at:"
echo "https://github.com/j-speers/infernalpw/commits"
