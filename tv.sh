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

		sleep 2

		# AUDIO="$(pactl list cards | awk -v RS='' '/SONY/')"
		# DEVICE="$(echo "$AUDIO" | grep 'Name:' | cut -f2 -d':' | xargs)"
		# PROFILE="$(echo "$AUDIO" | awk -v RS='Properties:' '/SONY/' | grep 'profile(s):' | grep -o 'output:[^,[:space:]]*' | grep stereo )"

		# pactl set-sink-profile "$DEVICE" "$PROFILE"

		# export PULSE_SOURCE="$(LANG=C pactl list | grep -A2 'Source #' | grep 'Name: ' | cut -d" " -f2 | grep "$DEVICE")"
		# export PULSE_SINK="$(LANG=C pactl list | grep -A2 'Sink #' | grep 'Name: ' | cut -d" " -f2 | grep "$DEVICE")"

		# sleep 1

		sed -i 's/^.*videoscreen\.screenmode.*$/<setting id="videoscreen.screenmode">WINDOW<\/setting>/' ~/.kodi/userdata/guisettings.xml

		kodi &

		sleep 1

		swaymsg '[app_id="Kodi"]' fullscreen toggle
		;;
	stop)
		pkill kodi
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
