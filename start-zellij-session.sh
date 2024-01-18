#!/bin/bash

repo_dir_marker='~/r/..'
work_dir_marker='~/w/..'
clone_r_marker='clone GitHub repo into ~/r/'
clone_w_marker='clone any repo into ~/w/'
kdash_marker='kdash'
bore_marker='bore'
freq_marker='recent: '

fre_store_file="/home/thomas/.cache/zellij-session-fre"

fzf_opts='--layout=reverse'

ZELLIJ_LAYOUT_DIR="/home/thomas/.dotfiles/zellij-layouts"

# Get all frequently accessed repos
freq=$(fre --sorted --store "$fre_store_file" | head -n 10 | sed "s/^/${freq_marker}/")

# Find all predefined zellij layout files expect default.kdl
zellij_layout_files=$(ls "$ZELLIJ_LAYOUT_DIR" | sed 's|.*/||' | sed 's|\..*||' | grep -v -w default | grep -v -w bore)

# Prepend our special cases
sessions=$(printf "$repo_dir_marker\n$work_dir_marker\n$freq\n$zellij_layout_files\n$clone_r_marker\n$clone_w_marker\n$kdash_marker\n$bore_marker\n")

selected_session=$(echo "$sessions" | fzf $fzf_opts)

function clone {
		url=$(list-fftabs | rg git | fzf $fzf_opts)

		re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+)(.git)*$"

		if [[ $url =~ $re ]]; then    
		    protocol=${BASH_REMATCH[1]}
		    separator=${BASH_REMATCH[2]}
		    hostname=${BASH_REMATCH[3]}
		    user=${BASH_REMATCH[4]}
		    repo=${BASH_REMATCH[5]}

				git clone "git@${hostname}:${user}/${repo}.git"
		else
			print "Failed parsing URL ${url}"
			exit 1
		fi
}

if [ "$selected_session" == "$repo_dir_marker" ]
then
	# Create a new session for any folder inside the ~/r directory
	subdir="$(ls ~/r | fzf $fzf_opts)"
	if [[ "$subdir" != "" ]]; then
		fre --add "~/r/$subdir" --store "$fre_store_file"
		[ -z ${SSH_TTY+x} ] && notify-send "Registering zellij path" "Adding '~/r/$subdir' to frequency store" --urgency=low --app-name=fre
	fi
	cd ~/r/$subdir
	# Attach to the session if it exists or otherwise create a new one
	exec zellij --layout "$ZELLIJ_LAYOUT_DIR/default.kdl" attach --create "$subdir" && exit
elif [ "$selected_session" == "$work_dir_marker" ]
then
	# Create a new session for any folder inside the ~/w directory
	subdir="$(ls ~/w | fzf $fzf_opts)"
	if [[ "$subdir" != "" ]]; then
		fre --add "~/w/$subdir" --store "$fre_store_file"
		[ -z ${SSH_TTY+x} ] && notify-send "Registering zellij path" "Adding '~/w/$subdir' to frequency store" --urgency=low --app-name=fre
	fi
	cd ~/w/$subdir
	# Attach to the session if it exists or otherwise create a new one
	exec zellij --layout "$ZELLIJ_LAYOUT_DIR/default.kdl" attach --create "$subdir" && exit
elif [ "$selected_session" == "$clone_r_marker" ]
then
	cd ~/r/
	clone
	sleep 3
elif [ "$selected_session" == "$clone_w_marker" ]
then
	cd ~/w/
	read -p "Enter repo SSH URL: " url
	git clone "$url"
	sleep 3
elif [ "$selected_session" == "$kdash_marker" ]
then
	exec kdash
elif [ "$selected_session" == "$bore_marker" ]
then
	read -p "Bore port to share: " BORE_PORT

	BORE_PORT="$BORE_PORT" exec zellij --layout "$ZELLIJ_LAYOUT_DIR/bore.kdl" attach --create bore && exit
elif [[ "$selected_session" == "$freq_marker"* ]]
then
	dir="$(echo "$selected_session" | sed "s/${freq_marker}//")"
	subdir="$(basename "$dir")"

	fre --add "$dir" --store "$fre_store_file"
	[ -z ${SSH_TTY+x} ] && notify-send "Registering zellij path" "Adding '$dir' to frequency store" --urgency=low --app-name=fre
	cd "$(echo "$dir" | sed "s/~/\/home\/thomas/")"
	# # Attach to the session if it exists or otherwise create a new one
	zellij --layout "$ZELLIJ_LAYOUT_DIR/default.kdl" attach --create "$subdir" && exit
else
	# Load a defined layout
	exec zellij --layout $ZELLIJ_LAYOUT_DIR/$selected_session.kdl
fi

