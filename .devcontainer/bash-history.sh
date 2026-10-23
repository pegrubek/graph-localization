# Shared, persistent history for interactive development shells.
export HISTFILE=/commandhistory/.bash_history
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth
shopt -s histappend

_graph_localization_history() {
    history -a
    history -n
}

# Preserve existing prompt hooks and avoid registering ours twice.
if [[ ! ${PROMPT_COMMAND[*]} =~ _graph_localization_history ]]; then
    PROMPT_COMMAND=(_graph_localization_history "${PROMPT_COMMAND[@]}")
fi

# Search commands by the prefix typed before the cursor.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
