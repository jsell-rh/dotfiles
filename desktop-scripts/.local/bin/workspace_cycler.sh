#!/bin/bash

# Get the name of the focused monitor
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Get the list of workspaces on the focused monitor into a bash array, sorted numerically
mapfile -t workspaces_on_monitor < <(hyprctl workspaces -j | jq -r --arg MON "$focused_monitor" '[.[] | select(.monitor == $MON) | .id] | sort | .[]')

# Get the ID of the active workspace
active_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Find the index of the active workspace within our array
current_index=-1
for i in "${!workspaces_on_monitor[@]}"; do
   if [[ "${workspaces_on_monitor[$i]}" = "${active_workspace}" ]]; then
       current_index=$i
       break
   fi
done

# If the active workspace is not on the focused monitor for some reason, exit
if [ "$current_index" == "-1" ]; then
    exit 0
fi

# Get the total number of workspaces on the monitor
workspace_count=${#workspaces_on_monitor[@]}

# If there's only one workspace, there's nothing to do
if [ "$workspace_count" -le 1 ]; then
    exit 0
fi

# Determine the direction for cycling
direction=$1

# Calculate the next index
if [ "$direction" == "next" ]; then
    next_index=$(((current_index + 1) % workspace_count))
elif [ "$direction" == "prev" ]; then
    next_index=$(((current_index - 1 + workspace_count) % workspace_count))
else
    echo "Usage: $0 [next|prev]"
    exit 1
fi

# Get the ID of the target workspace
target_workspace=${workspaces_on_monitor[$next_index]}

# Switch to the target workspace
hyprctl dispatch workspace "$target_workspace"