#!/bin/bash

### APPLICATIONS ###
sudo apt-get -y install iceweasel
sudo sed -i 's/^Exec.*/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Adwaita\/gtk-2.0\/gtkrc iceweasel %u/' /usr/share/applications/iceweasel.desktop
exit 0

### CUSTOM FONT ###
# Find directory of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Link the dotfiles
cd ~
ln -s $DIR/.*

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
mkfontscale
mkfontdir
sudo dpkg-reconfigure fontconfig
sudo dpkg-reconfigure fontconfig-config
