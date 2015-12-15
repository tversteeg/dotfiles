#!/bin/sh

# Install the tamsyn font
cd /tmp
wget http://www.fial.com/~scott/tamsyn-font/download/tamsyn-font-1.11.tar.gz

mkdir /tmp/tamsyn
cd /tmp/tamsyn
tar -zxvf /tmp/tamsyn-font-1.11.tar.gz

sudo mkdir -p /usr/local/share/fonts/bitmap
sudo chmod 777 /usr/local/share/fonts/bitmap
cd /usr/local/share/fonts/bitmap
mv /tmp/tamsyn/* .

fc-cache -fv | grep -i "tamsyn"
sudo dpkg-reconfigure fontconfig
sudo dpkg-reconfigure fontconfig-config
