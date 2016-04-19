#!/bin/bash

# Find directory of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$( readlink "$SOURCE" )"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

### APPLICATIONS ###
read -p "Install core packages? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt -y install firefox vim-gtk xfonts-terminus ristretto
fi

read -p "Install mpd music player with gimmix & mpc? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt -y install gimmix mpd mpc
	mkdir -p ~/.mpd
	cp $DIR/mpd.conf ~/.mpd
	sed -i "s/%USERDIR%/$( echo $HOME | sed -e 's/\//\\\//g' )/g" ~/.mpd/mpd.conf
	touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpdstate,tag_cache}
fi

# Vim addons
read -p "Install vim addon packages? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt -y install vim-pathogen vim-syntastic vim-youcompleteme
	mkdir -p ~/.vim/bundle
	cd ~/.vim/bundle
	git clone https://github.com/ctrlpvim/ctrlp.vim.git
	git clone https://github.com/scrooloose/syntastic.git
	git clone https://github.com/ervandew/supertab.git

	# GHC stuff
	read -p "- Install Haskell development packages & vim plugins? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt -y install hlint ghc-mod
		git clone https://github.com/eagletmt/ghcmod-vim.git
		git clone https://github.com/eagletmt/neco-ghc

		# Download correct syntax highlighting
		mkdir -p ~/.vim/syntax
		cd ~/.vim/syntax
		wget -nc https://raw.githubusercontent.com/sdiehl/haskell-vim-proto/master/vim/syntax/haskell.vim
		wget -nc https://raw.githubusercontent.com/sdiehl/haskell-vim-proto/master/vim/syntax/cabal.vim
	fi
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

read -p "Apply the Adwaita theme to iceweasel/icedove? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo sed -i 's/^Exec.*/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Adwaita\/gtk-2.0\/gtkrc iceweasel %u/' /usr/share/applications/iceweasel.desktop
	sudo sed -i 's/^Exec.*/Exec=env GTK2_RC_FILES=\/usr\/share\/themes\/Adwaita\/gtk-2.0\/gtkrc icedove %u/' /usr/share/applications/icedove.desktop
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