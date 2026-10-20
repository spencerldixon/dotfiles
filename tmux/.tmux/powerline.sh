#!/bin/sh

# Prints the current Spotify track for the status bar, or nothing when idle.
# Date, time and battery are rendered natively in status-right.

spotify_text_colour='magenta'

track=$(osascript ~/.tmux/current_track.scpt)

if [ -n "$track" ]; then
  printf '#[fg=%s]%s ' "$spotify_text_colour" "$track"
fi
