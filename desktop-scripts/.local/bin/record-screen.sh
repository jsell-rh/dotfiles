#!/bin/bash

# usage: record-screen.sh

PIDFILE="/tmp/wf-recorder.pid"
VIDEO_DIR="$HOME/Videos/Screencasts"
mkdir -p "$VIDEO_DIR"

if [ -f "$PIDFILE" ]; then
    # --- STOP RECORDING ---
    PID=$(cat "$PIDFILE")

    # Kill the recorder
    kill -SIGINT "$PID"
    rm "$PIDFILE"
    
    notify-send "Screen Recording" "Processing compression..."

    # Wait for file to finalize
    sleep 1
    
    # Find the raw file we just made
    RAW_FILE=$(ls -t "$VIDEO_DIR"/recording_*.mp4 | head -n1)

    if [ -n "$RAW_FILE" ]; then
        # Create a temp name for the compressed version
        COMPRESSED_FILE="${RAW_FILE%.mp4}_compressed.mp4"

        # --- COMPRESSION STEP ---
        # -crf 28: Higher number = more compression (23 is default, 28 is good for sharing)
        # -preset fast: Balance between speed and size
        ffmpeg -i "$RAW_FILE" -vcodec libx264 -crf 28 -preset fast -acodec copy "$COMPRESSED_FILE" -y

        # If compression succeeded, replace the original
        if [ $? -eq 0 ]; then
            mv "$COMPRESSED_FILE" "$RAW_FILE"
            FINAL_MSG="Compressed & Saved to $(basename "$RAW_FILE")"
        else
            FINAL_MSG="Compression failed. Saved raw file."
            # Clean up partial file if ffmpeg failed
            [ -f "$COMPRESSED_FILE" ] && rm "$COMPRESSED_FILE"
        fi

        # Copy to clipboard
        echo "file://$RAW_FILE" | wl-copy -t text/uri-list
        notify-send "Screen Recording Stopped" "$FINAL_MSG\nCopied to clipboard!"
    fi

else
    # --- START RECORDING ---
    FILENAME="$VIDEO_DIR/recording_$(date +'%Y%m%d_%H%M%S').mp4"
    GEOMETRY=$(slurp)

    if [ -z "$GEOMETRY" ]; then
        exit
    fi

    notify-send "Screen Recording Started" "Press hotkey to stop."

    # Kept your original "FIX" settings for the recording phase
    # It is important to keep this fast so the UI doesn't lag while recording
    wf-recorder -g "$GEOMETRY" -c libx264 -p preset=ultrafast -p crf=25 -x yuv420p -f "$FILENAME" &

    # Save PID
    echo $! > "$PIDFILE"
fi
