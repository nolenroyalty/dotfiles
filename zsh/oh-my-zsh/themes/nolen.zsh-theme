# ------------------------------------------------------------------------------
#          FILE:  nolen.zsh-theme
#   DESCRIPTION:  oh-my-zsh theme file.
#        AUTHOR:  Kévin Gomez (geek63@gmail.com) modified by Nolen Royalty
#       VERSION:  1.0.0
#    SCREENSHOT:
# ------------------------------------------------------------------------------


if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
    # Use #{PWD/#$HOME/~} so that we still condense $HOME to ~, but otherwise don't show path variables in the prompt
    # Otherwise eg. ~/.oh-my-zsh will display as $ZSH.
    # Note that this only happens on some systems: on OSX using %~ works fine, but on Linux this trick is needed
    PROMPT='[%{$fg[red]%}%n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%}:%{$fg[cyan]%}${PWD/#$HOME/~}%{$reset_color%}$(git_prompt_info)]
%# '

    ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[green]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY=""
    ZSH_THEME_GIT_PROMPT_CLEAN=""

    # I don't find the git prompt info on the right side to be useful, and knowing what time you ran a command is very nice
    RPROMPT="%{$fg[green]%}%@%{$reset_color%}"

    ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
    ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
    ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
    ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
    ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} "
    ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"
else
    PROMPT='[%n@%m:${PWD/#$HOME/~}$(git_prompt_info)]
%# '

    ZSH_THEME_GIT_PROMPT_PREFIX=" on"
    ZSH_THEME_GIT_PROMPT_SUFFIX=""
    ZSH_THEME_GIT_PROMPT_DIRTY=""
    ZSH_THEME_GIT_PROMPT_CLEAN=""

    RPROMPT="%{$fg[green]%}%@%{$reset_color%}"

    ZSH_THEME_GIT_PROMPT_ADDED=" ✚"
    ZSH_THEME_GIT_PROMPT_MODIFIED=" ✹"
    ZSH_THEME_GIT_PROMPT_DELETED=" ✖"
    ZSH_THEME_GIT_PROMPT_RENAMED=" ➜"
    ZSH_THEME_GIT_PROMPT_UNMERGED=" "
    ZSH_THEME_GIT_PROMPT_UNTRACKED=" ✭"
fi
