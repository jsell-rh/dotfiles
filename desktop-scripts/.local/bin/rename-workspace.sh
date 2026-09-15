#!/bin/bash
LABELS_FILE="$HOME/.config/hypr/workspace-labels"
touch "$LABELS_FILE"

ACTIVE_ID=$(hyprctl activeworkspace -j | jq -r '.id')
CURRENT_LABEL=$(grep "^${ACTIVE_ID}=" "$LABELS_FILE" | cut -d= -f2-)

NEW_LABEL=$(echo "$CURRENT_LABEL" | rofi -dmenu -p "Label for workspace $ACTIVE_ID" -theme-str 'window {width: 300px;}')

if [ $? -ne 0 ]; then
    exit 0
fi

sed -i "/^${ACTIVE_ID}=/d" "$LABELS_FILE"

if [ -n "$NEW_LABEL" ]; then
    echo "${ACTIVE_ID}=${NEW_LABEL}" >> "$LABELS_FILE"
    hyprctl dispatch renameworkspace "$ACTIVE_ID" "${ACTIVE_ID}: ${NEW_LABEL}"
else
    hyprctl dispatch renameworkspace "$ACTIVE_ID" "$ACTIVE_ID"
fi
