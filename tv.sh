#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo 'Too many/few arguments, expecting "start" or "stop"' >&2
	exit 1
fi

TV=$(swaymsg -t get_outputs -r | jq '.[]|select(.make | startswith("Sony"))|.name' -r)

case $1 in
	start)
		swaymsg workspace 9 output "$TV"
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

		sleep 2

		# Play message so audio source can be adjusted
		curl -H "Content-type: application/json" -d   '{"jsonrpc":"2.0","id":1,"method":"Gui.ShowNotification","params":{"title":"Sound Check","message":"","displaytime":1500}}' http://localhost:2716/jsonrpc -u kodi:kodi
		;;
	stop)
		pkill kodi
		swaymsg output "$TV" disable
		;;
	*)
		echo 'Expected "start" or "stop"' >&2
		exit 1
esac
