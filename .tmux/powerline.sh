#!/bin/sh

#LSEP=⮁
#RSEP=

# Monokai theme
#spotify_colour='#1ABD53'
#date_time_colour='colour55'
#spotify_text_colour='#eeeeee'
#date_time_text_colour='#eeeeee'
#black='colour236'

# Base16-Eighties Theme
#date_time_colour='colour04'
#spotify_text_colour='colour15'
#date_time_text_colour='colour15'
#spotify_colour='colour01'
#black="colour19"

## Gruvbox theme
#date_time_colour='colour10'
#spotify_text_colour='colour00'
#date_time_text_colour='colour00'
#spotify_colour="colour06"
#black="colour00"

# Hybrid theme
date_time_colour=black
spotify_text_colour='colour15'
date_time_text_colour=white
spotify_colour=blue
black=black

SPOTIFY="#[fg=${spotify_colour},bg=${black},nobold,noitalics,nounderscore]$RSEP#[fg=${spotify_text_colour},bg=${spotify_colour},nobold,noitalics,nounderscore] $(osascript ~/.tmux/current_track.scpt)"

DATE="#[fg=${date_time_colour},bg=${spotify_colour},nobold,noitalics,nounderscore] $RSEP#[fg=${date_time_text_colour},bg=${date_time_colour},nobold,noitalics,nounderscore] $(date +'%D')"

TIME="#[fg=${date_time_text_colour},bg=${date_time_colour},nobold,noitalics,nounderscore]#[fg=${date_time_text_colour},bg=${date_time_colour},nobold,noitalics,nounderscore] $(date +'%H:%M')"

echo "$SPOTIFY" "$DATE | $TIME" | sed 's/ *$/ /g'
