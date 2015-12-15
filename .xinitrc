#!/bin/sh

DEFAULT_SESSION=startxfce4

case $1 in
xfce4)
	exec startxfce4
	;;
*)
	exec $DEFAULT_SESSION
	;;
esac
