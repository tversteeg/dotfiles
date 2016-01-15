#!/bin/bash

battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
notify-send "Battery low" "Battery level is ${battery_level}%!"
if [ $battery_level -le 80 ]
then
    notify-send "Battery low" "Battery level is ${battery_level}%!"
fi
