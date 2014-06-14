# It's nice to control how your tab titles are set, and when you're writing for yourself
# You don't have to worry about supporting terminals you don't use :D

function set-tab-title () {
    echo -ne "\e];$@\a"
}

function title {
    local screen_name=${STY#*.}
}    
