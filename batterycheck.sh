#!/bin/bash

battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
if [ $battery_level -le 50 ]
then
	paplay /usr/share/sounds/purple/receive.wav ;
	export DISPLAY=:0.0 && notify-send -i /usr/share/icons/Adwaita/48x48/status/battery-caution.png -u critical "Battery low" "Battery level is ${battery_level}%!"
fi
