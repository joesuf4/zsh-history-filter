export HISTORY_FILTER_VERSION="0.4.4-joesuf4"
zmodload zsh/pcre

# overwrite the history file so that it
# retro-actively applies the currently set filters
function rewrite_history() {
    local new_history="$HISTFILE.bak"
    local excluded=0

    while read -r entry; do
        local command="${entry#*;}"

        if ! _matches_filter "$command"; then
            echo "$entry"
        else
            ((++excluded))
            printf "\rExcluded %d entries" excluded >&2
        fi
    done <"$HISTFILE" >"$new_history"
    printf "\n" >&2
    mv "$new_history" "$HISTFILE"
}


function _matches_filter() {
    local value
    for value in $HISTORY_FILTER_EXCLUDE; do
        if [[ "$1" -pcre-match "$value" ]]; then
            return 0
        fi
    done
    return 1
}


function _history_filter() {
    if _matches_filter "$1"; then
        if [[ -z "$HISTORY_FILTER_SILENT" ]]; then
            printf "Excluding command from history\n" >&2
        fi
        return 2
    else
        return 0
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _history_filter
