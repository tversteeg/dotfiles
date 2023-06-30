#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo 'Too many/few arguments, expecting "start" or "stop"' >&2
	exit 1
fi

SWAYSOCK="/run/user/$(id -u thomas)/sway-ipc.$(id -u thomas).$(pgrep -x sway).sock"

TABLET=$(swaymsg -s $SWAYSOCK -t get_outputs -r | jq '.[]|select(.model | startswith("Kamvas"))|.name' -r)

case $1 in
	start)
    swaymsg -s $SWAYSOCK exec "notify-send 'Tablet $TABLET connected'"

    sleep 3

		swaymsg -s $SWAYSOCK workspace "tablet" output "$TABLET"
		swaymsg -s $SWAYSOCK output "$TABLET" enable
		swaymsg -s $SWAYSOCK output "$TABLET" scale 1 pos 0 2160
		swaymsg -s $SWAYSOCK input type:tablet_pad map_to_output "$TABLET"
		swaymsg -s $SWAYSOCK input type:tablet_tool map_to_output "$TABLET"

    input-remapper-control --command autoload

		swaymsg -s $SWAYSOCK 'assign [class="Aseprite"] workspace tablet'
    swaymsg -s $SWAYSOCK exec "/home/thomas/.steam/steam/steamapps/common/Aseprite/aseprite"
		;;
	stop)
    swaymsg -s $SWAYSOCK exec "notify-send 'Tablet $TABLET disconnected'"

    sleep 3

		swaymsg -s $SWAYSOCK output "$TABLET" disable
		;;
	*)
		echo 'Expected "start" or "stop"' >&2
		exit 1
esac
