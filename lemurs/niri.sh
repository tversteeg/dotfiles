#!/bin/sh

export MOZ_ENABLE_WAYLAND=1

exec systemd-cat niri
