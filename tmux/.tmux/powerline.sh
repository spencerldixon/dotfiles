#!/bin/sh

LSEP=
RSEP=

spotify_text_colour=magenta
spotify_colour=default

date_time_colour=brightblack
date_time_text_colour=brightwhite

SPOTIFY="#[fg=${spotify_text_colour},bg=${spotify_colour}] $(osascript ~/.tmux/current_track.scpt)"
DATE="#[fg=brightblack,bg=default]$LSEP#[fg=${date_time_text_colour},bg=${date_time_colour}] $(date +'%D')"
TIME="#[fg=${date_time_text_colour},bg=${date_time_colour}]#[fg=${date_time_text_colour},bg=${date_time_colour}] $(date +'%H:%M')"

echo "$SPOTIFY" "$DATE | $TIME" | sed 's/ *$/ /g'
