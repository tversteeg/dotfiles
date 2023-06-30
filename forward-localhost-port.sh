#!/bin/bash

sudo iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp --dport $1 -j DNAT --to-destination $2
sudo iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
sudo sysctl -w net.ipv4.conf.all.route_localnet=1

