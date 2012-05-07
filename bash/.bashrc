#using ~/.bash_aliases for...aliases.
source ~/.bash_aliases
#using ~/.profile for paths
source ~/.profile

#terminal settings stuff, kind of works...nice prompt
export PS1="\\[${COLOR_GREEN}\\]\\u:\w$ \\[${COLOR_NC}\\]"
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

bind "set completion-ignore-case on" # note: bind is used instead of setting these in .inputrc.  This ignores case in bash completion
#bind "set show-all-if-ambiguous On" # this allows you to automatically show completion without double tab-ing

#these two lines makes c-w awesome! and my funky c-backspace implementation
stty werase undef
bind '"\C-w": backward-kill-word'
bind '"\e[[ee": backward-kill-word'
bind '"\e[[dd": kill-word'
#bind '"[3~": kill-word'
#bind '"\e[3~": forward-kill-word'
#this is awesome, cd without using cd!
shopt -s autocd
#recursive globbing with **
shopt -s globstar
#so that history commands are confirmed instead of blindly executed
shopt -s histverify

#alias py32='arch -i386 python'
#attempting to make ctrl-w better
#LOLOOLOLOLOL
#COMP_WORDBREAKS=$COMP_WORDBREAKS/
#HOLYSHIT THAT BREAKS EVERYTHING FUCK.THAT.NOISE
#because apple is dumb as shit sometimes
#alias easy_install='sudo python /Library/Python/2.7/site-packages/easy_install.py'
stty -ixon
  if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
  fi
# Setting PATH for Python 2.7 The orginal version is saved in 
#.bash_profile.pysave 
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}" export PATH
#
##for haskell
#export PATH="$HOME/Library/Haskell/bin:$PATH"
#
##Adding Racket to PATH
#export PATH="/Applications/Racket\ v5.2.1/bin:$PATH"

##
# Your previous /Users/scale/.bash_profile file was backed up as 
# /Users/scale/.bash_profile.macports-saved_2011-12-22_at_18:34:15
##

# MacPorts Installer addition on 2011-12-22_at_18:34:15: adding an appropriate 
#PATH variable for use with MacPorts. export 
#PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

#export PYTHONSTARTUP=~/.pythonrc



# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
#export PATH

