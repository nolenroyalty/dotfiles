# General lazy aliases
alias e='extract' # Extract!
alias igrep='grep -i' # Case insensitive grep
alias zzz='source ~/.zshrc'
alias duh='du -h'
alias dff="df -lh|grep -v TimeMachine|grep -v /private/var/vm|awk ' { print \$2,"\t"\$3,"\t"\$4,"\t"\$5 }'"

# Useful paths
alias code='cd $CODEDIR'
alias dotf='cd $CODEDIR/dotfiles'
alias gmdir='cd $GMDIR'
alias down='cd ~/Downloads/'

# Fast config editing
alias vv='vim ~/.vimrc'
alias zz='vim ~/.zshrc'
alias pp='vim ~/.pentadactylrc'
alias bp='bpython'

#git aliases
alias ga='git add'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gm='git commit'
alias gp='git push origin HEAD'
alias gc='git checkout'
alias gcb='git checkout -b'

# 'x' for 'eXpand'
alias xx='command atool -x'

# The node stuff we installed via an installer
# idk the right way to manage this yet, let's not think about it too hard
alias node-lts='/usr/local/bin/node'
alias npm-lts='/usr/local/bin/npm'

#try to stop those really annoying corrections...
#alias sudo='nocorrect sudo'

#sometimes, you just gotta use ed
alias ed='ed -p:'
