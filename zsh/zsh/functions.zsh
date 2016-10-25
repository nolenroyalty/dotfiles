# I almost always want files that *contain* something, not necessarily match it exactly
fff () {
    find ${2-.} -iname "*$1*"
}

tt () {
    livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best}
}

rr () {
    mkdir -p ~/Desktop/streams/$1; livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1.mp4
}

ttv () {
    livestreamer $1 ${2:=source} --player-passthrough=hls 
}

rrw () {
    while true; do mkdir -p $HOME/desktop/streams/$1; mv $HOME/Desktop/streams/$1/$1.mp4 $HOME/Desktop/streams/$1/$1-`date "+%m-%d_%H-%M-%S"`.mp4; livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1.mp4; sleep 30; done
}
