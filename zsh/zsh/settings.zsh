# Blank pushd goes to home
setopt PUSHD_TO_HOME

# protect against crazy rm...
setopt RM_STAR_WAIT

# Python doesn't find this by default D:
export PYTHONSTARTUP=~/.pythonrc.py

# I like color
export TERM=xterm-256color

# Don't use hosts file for ssh completion, because I have a lot of stuff blocked in there
zstyle ':completion:*' hosts off
stty -ixon
