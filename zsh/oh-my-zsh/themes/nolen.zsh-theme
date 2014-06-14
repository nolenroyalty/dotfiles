function color {
    if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
        echo "%{$fg[$1]%}$2%{$reset_color%}"
    else
        echo $2
    fi
}

function screen_prompt_info {
    echo ${STY#*.}|perl -pe "s/^(.+)$/ [screen:\1]/"
}

# svn and hg prompt_info functions don't return non-zero exit codes...ever
# So we work around that.
function vcs_prompt_info {
    git_prompt_info || (in_svn && svn_prompt_info) || (hg branch &>/dev/null && hg_prompt_info)
}

# Use #{PWD/#$HOME/~} so that we still condense $HOME to ~, but otherwise don't show path variables in the prompt
# Otherwise eg. ~/.oh-my-zsh will display as $ZSH.
# Note that this only happens on some systems: %~ does what I want on OSX but not Linux.

CWD=$(color cyan '${PWD/#$HOME/~}]')
USER=$(color red "[%n")
HOST_NAME=$(color magenta "%m")
CVS_INFO=$(color yellow '$(vcs_prompt_info)')
TIME=$(color green '[$(date +%I:%M%p)]')
SCREEN_SESSION=$(color blue '$(screen_prompt_info)')

AT=$(color white @)
COLON=$(color white :) # the things I do for a nice prompt

TOP_PROMPT="$TIME$SCREEN_SESSION$CVS_INFO $USER$AT$HOST_NAME$COLON$CWD"
BOTTOM_PROMPT=$(color white "%# ")
PROMPT=$TOP_PROMPT$'\n'$BOTTOM_PROMPT
unset CWD USER HOST_NAME CVS_INFO TIME SCREEN_SESSION TOP_PROMPT BOTTOM_PROMPT

ZSH_THEME_GIT_PROMPT_PREFIX=" [git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_HG_PROMPT_PREFIX=" [hg:"
ZSH_THEME_HG_PROMPT_SUFFIX="]"
ZSH_THEME_SVN_PROMPT_PREFIX=" [svn:"
ZSH_THEME_SVN_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_HG_PROMPT_DIRTY=""
ZSH_THEME_SVN_PROMPT_DIRTY=""
