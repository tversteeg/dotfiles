#!/bin/sh

# Load font location
xset +fp /usr/local/share/fonts/bitmap/tamsyn-font-1.11/

DEFAULT_SESSION=startxfce4

case $1 in
xfce4)
	exec startxfce4
	;;
*)
	exec $DEFAULT_SESSION
	;;
esac
