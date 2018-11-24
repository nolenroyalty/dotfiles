# I almost always want files that *contain* something, not necessarily match it exactly
fff () {
    find ${2-.} -iname "*$1*"
}

tt () {
    streamlink ${2:=twitch}.${4:=tv}/$1 ${3:=best} --twitch-disable-hosting
}

rr () {
    mkdir -p ~/Desktop/streams/$1
    streamlink ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1.mp4 --twitch-disable-hosting
}

ttv () {
    streamlink $1 ${2:=source} --player-passthrough=hls
}

rrw () {
    while true; do 
        mkdir -p $HOME/desktop/streams/$1;
        d=$(date "+%m-%dT%H-%M-%S")
        streamlink ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1-$d.mp4 --twitch-disable-hosting;
        sleep 30; 
    done
}

torclear () {
    rm ~/Downloads/*.torrent
}

m3uclear () {
    rm ~/Downloads/tors/*/*.m3u; rm ~/Downloads/tors/*/*.cue; rm ~/Downloads/tors/*/*.CUE; rm ~/Downloads/tors/*/*.log;
}
