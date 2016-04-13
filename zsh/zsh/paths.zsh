# Paths and a few other settings
path_add () {
    if [ -e $1 ]; then
        export PATH=$1:${PATH}
    fi
}

export PATH=/usr/bin:/bin:/usr/sbin:/sbin
export PATH=/usr/local/bin:/usr/local/sbin:${PATH}

path_add /usr/local/git/bin
path_add $HOME/.rbenv/bin
path_add $HOME/bin

# Awesome or awful?  You decide
dotfiles=$(ls -la $HOME|grep '^l.*dotfiles'|perl -pe 's/.* (\/.*dotfiles).*/\1/'|head -1)
path_add $dotfiles/bin

#if hash rbenv; then
    #eval "$(rbenv init -)";
#fi
