# I almost always want files that *contain* something, not necessarily match it exactly
fff () {
    find ${2-.} -iname "*$1*"
}

tt () {
    livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best} --twitch-oauth-token $TWITCH_TOKEN
}

rr () {
    mkdir -p ~/Desktop/streams/$1; livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1.mp4 --twitch-oauth-token $TWITCH_TOKEN
}

ttv () {
    livestreamer $1 ${2:=source} --player-passthrough=hls --twitch-oauth-token $TWITCH_TOKEN
}

rrw () {
    while true; do mkdir -p $HOME/desktop/streams/$1; mv $HOME/Desktop/streams/$1/$1.mp4 $HOME/Desktop/streams/$1/$1-`date "+%m-%d_%H-%M-%S"`.mp4; livestreamer ${2:=twitch}.${4:=tv}/$1 ${3:=best} -o ~/Desktop/streams/$1/$1.mp4 --twitch-oauth-token $TWITCH_TOKEN; sleep 30; done
}

torclear () {
    rm ~/Downloads/*.torrent
}

m3uclear () {
    rm ~/Downloads/tors/*/*.m3u; rm ~/Downloads/tors/*/*.cue; rm ~/Downloads/tors/*/*.CUE; rm ~/Downloads/tors/*/*.log;
}
