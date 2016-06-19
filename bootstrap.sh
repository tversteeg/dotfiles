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
	sudo apt-get -y install firefox vim-gtk xfonts-terminus ristretto htop
fi

read -p "Install mpd music player with gimmix & mpc? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo apt-get -y install gimmix mpd mpc
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
	sudo apt-get -y install vim-gtk

	mkdir -p ~/.vim/autoload ~/.vim/bundle
	cd ~/.vim/autoload
	wget -nc https://tpo.pe/pathogen.vim
	cd ~/.vim/bundle
	git clone https://github.com/ctrlpvim/ctrlp.vim.git
	#git clone https://github.com/scrooloose/syntastic.git
	git clone https://github.com/godlygeek/tabular.git
	#git clone https://github.com/ervandew/supertab.git	

	read -p "- Install markdown preview server & vim plugin? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get -y install xdg-utils curl nodejs
		sudo npm -g install instant-markdown-d

		cd /tmp
		git clone https://github.com/suan/vim-instant-markdown.git
		mkdir -p ~/.vim/after/ftplugin/markdown
		cp vim-instant-markdown/after/ftplugin/markdown/* ~/.vim/after/ftplugin/markdown
	fi

	read -p "- Build and install YouCompleteMe server & vim plugins? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get -y install build-essential cmake libclang1 python-dev python3-dev

		cd ~/.vim/bundle
		git clone https://github.com/Valloric/YouCompleteMe.git
		cd YouCompleteMe
		git submodule update --init --recursive

		mkdir -p /tmp/ycm_build
		cd /tmp/ycm_build
		cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
		cmake --build . --target ycm_core --config Release

		cd ~/.vim/bundle/YouCompletMe
		./install.py --clang-completer

		cd ~/.vim/bundle
		git clone https://github.com/rdnetto/YCM-Generator.git
	fi

	# GHC stuff
	read -p "- Install Haskell development packages & vim plugins? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get -y install hlint ghc-mod

		cd ~/.vim/bundle
		git clone https://github.com/eagletmt/ghcmod-vim.git
		git clone https://github.com/eagletmt/neco-ghc.git
		git clone https://github.com/Shougo/vimproc.vim.git
		cd vimproc.vim
		make

		cd /tmp
		wget https://gist.githubusercontent.com/lcd047/7796203/raw/f3df4fd9e2f1e3818492577bac52aca61bb5fa9c/ghc-mod.sh
		sudo cp /tmp/ghc-mod.sh /usr/bin

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
	SYMS="$(find $DIR -type f -name .\*)"
	SYMNAMES="$(find $DIR -type f -name .\* -printf "%f ")"
	echo "Linking: $SYMNAMES"
	cd ~
	rm -f $SYMNAMES
	while read -r line; do
		ln -s $line
	done <<< "$SYMS"

	mkdir -p ~/.vim/ftplugin
	cd ~/.vim/ftplugin
	ln -s $DIR/ftplugin/*.vim

	mkdir -p ~/.vim/syntax
	cd ~/.vim/syntax
	ln -s $DIR/syntax/*.vim
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
