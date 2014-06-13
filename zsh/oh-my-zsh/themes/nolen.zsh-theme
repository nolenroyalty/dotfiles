color() {
    if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
        echo "%{$fg[$1]%}$2%{$reset_color%}"
    else
        echo $2
    fi
}

# Use #{PWD/#$HOME/~} so that we still condense $HOME to ~, but otherwise don't show path variables in the prompt
# Otherwise eg. ~/.oh-my-zsh will display as $ZSH.
# Note that this only happens on some systems: %~ does what I want on OSX but not Linux.
CWD=$(color cyan '${PWD/#$HOME/~}')
USER=$(color red %n)
HOST_NAME=$(color magenta %m)
GIT=$(color yellow '$(git_prompt_info)')
TIME=$(color green %@)

TOP_PROMPT="[$TIME] [$USER@$HOST_NAME:$CWD]$GIT"
BOTTOM_PROMPT=$'\n''%# ' # Newlines in a zsh prompt are weird
PROMPT=$TOP_PROMPT$BOTTOM_PROMPT
unset CWD USER HOST_NAME GIT TIME TOP_PROMPT BOTTOM_PROMPT # using local for these variables doesn't seem to work

ZSH_THEME_GIT_PROMPT_PREFIX=" ["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_DIRTY="" # By default this is a *, which is annoying
