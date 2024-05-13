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
path_add /usr/local/share/dotnet/

path_add /opt/homebrew/Cellar/node/21.2.0/bin/

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

# Awesome or awful?  You decide
dotfiles=$(ls -la $HOME|grep '^l.*dotfiles'|perl -pe 's/.* (\/.*dotfiles).*/\1/'|head -1)
path_add $dotfiles/bin

if [[ -z "$CODEDIR" ]]; then
    export GOPATH=$HOME/go
else
    export GOPATH=$CODEDIR/go
fi

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi
#if hash rbenv; then
    #eval "$(rbenv init -)";
#fi
