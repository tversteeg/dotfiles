dropbox start

dunst -cconf ~/.config/dunst/dunstrc &

python .linconnect/LinConnectServer/main/linconnect_server.py &

export RSYNC_PASSWORD='rsync'

lsyncd -rsync /media/HDD/cubie thomas@192.168.1.20::cubie

startx
