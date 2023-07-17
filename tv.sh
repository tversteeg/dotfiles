#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo 'Too many/few arguments, expecting "start" or "stop"' >&2
	exit 1
fi

TV=$(swaymsg -t get_outputs -r | jq '.[]|select(.make | startswith("Sony"))|.name' -r)

case $1 in
	start)
		swaymsg workspace "tv" output "$TV"
		swaymsg output "$TV" enable
		# Focus to workspace
		swaymsg workspace "tv"
		#chromium --app-id=akkheaabpnkfhcaebdhneikfekamanod --start-fullscreen --ozone-platform-hint=auto &
		jellyfinmediaplayer --windowed
		# Move mouse back
		swaymsg workspace "dev"
		;;
	stop)
		killall jellyfinmediaplayer
		swaymsg output "$TV" disable
		;;
	aseprite)
		swaymsg create_output HEADLESS-1
		swaymsg output HEADLESS-1 resolution 2000x1200
		swaymsg output HEADLESS-1 enable
		swaymsg focus output HEADLESS-1
		swaymsg workspace steam output HEADLESS-1
		swaymsg 'workspace steam; for_window [class="Aseprite"] fullscreen enable; exec ~/.steam/steam/steamapps/common/Aseprite/aseprite'
		wayvnc -v -C /home/thomas/.config/wayvnc/config -o HEADLESS-1 0.0.0.0
		swaymsg output HEADLESS-1 disable 
		;;
	*)
		echo 'Expected "start" or "stop"' >&2
		exit 1
esac
