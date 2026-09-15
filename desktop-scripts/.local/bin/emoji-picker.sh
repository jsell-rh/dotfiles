#!/bin/bash

EMOJI_FILE="$HOME/.config/sway/emojis.txt"

if ! command -v wtype &> /dev/null; then
    echo "Error: wl-type not found. Please install it."
    exit 1
fi

# Read emojis from the file, format them as "name emoji" for wmenu display,
# and pipe the list to wmenu.
# wmenu will output the full line selected by the user (e.g., "😄 smile").
selected_line=$(cat "$EMOJI_FILE" | awk -F':' '{print $1 " " $2}' | wmenu -p "Emoji:")

# Check if the user selected an emoji (i.e., the output is not empty)
if [ -z "$selected_line" ]; then
    # User cancelled the selection (e.g., pressed Escape)
    exit 0
fi
echo "$selected_line"
# Extract only the emoji character from the selected line.
# This assumes the format "<emoji> <name>" and takes the first field.
emoji_char=$(echo "$selected_line" | awk '{print $1}')

# Copy the extracted emoji character to the Wayland clipboard
# The -n flag prevents a newline from being copied
echo -n "$emoji_char" | wl-copy

wtype "$emoji_char"

exit 0

