#!/bin/bash

repo_dir_marker='~/r/..'
work_dir_marker='~/w/..'
clone_r_marker='clone GitHub repo into ~/r/'
clone_w_marker='clone any repo into ~/w/'
port_forward_marker='forward k8 port'

fzf_opts='--layout=reverse'

# Find all predefined zellij layout files expect default.kdl
zellij_layout_files=$(find "$ZELLIJ_LAYOUT_DIR" -type f | sed 's|.*/||' | sed 's|\..*||' | grep -v -w default)

# Prepend our special cases
sessions=$(printf "$repo_dir_marker\n$work_dir_marker\n$zellij_layout_files\n$clone_r_marker\n$clone_w_marker\n$port_forward_marker\n")

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
	cd ~/r/$subdir
	# Attach to the session if it exists or otherwise create a new one
	zellij --layout "$ZELLIJ_LAYOUT_DIR/default.kdl" attach --create "$subdir" && exit
elif [ "$selected_session" == "$work_dir_marker" ]
then
	# Create a new session for any folder inside the ~/w directory
	subdir="$(ls ~/w | fzf $fzf_opts)"
	cd ~/w/$subdir
	# Attach to the session if it exists or otherwise create a new one
	zellij --layout "$ZELLIJ_LAYOUT_DIR/default.kdl" attach --create "$subdir" && exit
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
elif [ "$selected_session" == "$port_forward_marker" ]
then
	pod="$(kubectl get pods -o name | fzf)"
	read -p "Enter port for '$pod': " port
	echo $port
	kubectl port-forward "$pod" "$port:$port"
	sleep 3
else
	# Load a defined layout
	zellij --layout $ZELLIJ_LAYOUT_DIR/$selected_session.kdl && exit
fi

