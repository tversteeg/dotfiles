#!/bin/bash

# Find directory of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

### APPLICATIONS ###
read -p "Install core packages? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt-get -y install iceweasel vim-gtk
fi

# Vim addons
read -p "Install vim addon packages? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt-get -y install vim-pathogen vim-syntastic vim-youcompleteme
fi

# Link the dotfiles
read -p "Create symlinks for the dotfiles? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	ls ls -l $DIR/.[^.]* | less
	cd ~
	ln -s $DIR/.*
fi

### CUSTOM SCRIPTS ###
read -p "Add a battery notification to cron? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Add battery notification
	mkdir -p ~/.local/etc
	cp $DIR/batterycheck.sh ~/.local/etc
	chmod 777 ~/.local/etc

	# Add scripts to cron
	TEMP=$(mktemp)
	echo "* * * * * \"/home/$(users)/.local/etc/batterycheck.sh\"" > ${TEMP}
	crontab ${TEMP}
	rm -f ${TEMP}
fi

read -p "Apply the Adwaita theme to iceweasel? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo sed -i 's/^Exec.*/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Adwaita\/gtk-2.0\/gtkrc iceweasel %u/' /usr/share/applications/iceweasel.desktop
fi

### CUSTOM FONT ###
read -p "Download & install the tamsyn font? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
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
fi
