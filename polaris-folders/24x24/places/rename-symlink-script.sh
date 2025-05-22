#!/bin/bash

# Check if we're in a valid directory
[ ! -d "." ] && echo "Error: Not in a valid directory" >&2 && exit 1

# Find all symlinks and process them
find . -maxdepth 1 -type l | while read -r link; do
    # Get the target path
    target=$(readlink "$link")
    
    # Create backup of original symlink
    #cp -P "$link" "${link}.bak"
    
    # Replace the text in the target path
    new_target=${target//oomox/lachesis}
    
    # Remove old symlink and create new one
    unlink "$link"
    ln -s "$new_target" "$(basename "$link")"
    
    echo "Processed symlink: $link"
done
