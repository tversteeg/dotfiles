#!/bin/bash

OUTPUT="HDMI-A-2"
TABLET="HUION Huion Tablet_GS1331 Pad pad"
TOUCH="HUION Huion Tablet_GS1331 Touch Strip pad"
PEN="HUION Huion Tablet_GS1331 Pen stylus"

swaymsg output "$OUTPUT" enable

xsetwacom set "$PEN" MapToOutput "$OUTPUT"
xsetwacom set "$TABLET" MapToOutput "$OUTPUT"

xsetwacom set "$TABLET" button "1" key "+Control_L +z"
xsetwacom set "$TABLET" button "2" key "+Control_L +Shift +z"
xsetwacom set "$TABLET" button "3" key "m"
xsetwacom set "$TABLET" button "8" key "+"
xsetwacom set "$TABLET" button "9" key "-"

xsetwacom set "$TABLET" button "10" key "Control_L"
xsetwacom set "$TABLET" button "11" key "Alt_L"
xsetwacom set "$TABLET" button "12" key "Shift_L"
