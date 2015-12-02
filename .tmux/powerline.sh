#!/bin/sh

# color236 - dark grey
# color55 - dark purple
# color98 - light purple
# color59 - grey

LSEP=⮁
RSEP=

# if ioreg hogs the CPU
# battery_perc=' na '
# battery_perc=$(ioreg -l | grep -i capacity | tr '\n' ' | ' | awk '{printf("%.2f%%\n", $10/$5 * 100)}')

spotify_colour='#1ABD53'
date_time_colour='colour55'
text_colour='#eeeeee'
black='colour236'

SPOTIFY="#[fg=${spotify_colour},bg=${black},nobold,noitalics,nounderscore]$RSEP#[fg=${text_colour},bg=${spotify_colour},nobold,noitalics,nounderscore] $(osascript ~/.tmux/current_track.scpt)"

DATE="#[fg=${date_time_colour},bg=${spotify_colour},nobold,noitalics,nounderscore] $RSEP#[fg=${text_colour},bg=${date_time_colour},nobold,noitalics,nounderscore] $(date +'%D')"

TIME="#[fg=${text_colour},bg=${date_time_colour},nobold,noitalics,nounderscore]|#[fg=${text_colour},bg=${date_time_colour},bold,noitalics,nounderscore] $(date +'%H:%M')"

echo "$SPOTIFY $DATE $TIME" | sed 's/ *$/ /g'
