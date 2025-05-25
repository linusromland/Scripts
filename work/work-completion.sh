#!/bin/bash

_work_completions() {
    local cur prev opts

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Define top-level commands
    if [[ $COMP_CWORD -eq 1 ]]; then
        opts="vpn remote"
    elif [[ $COMP_CWORD -eq 2 && "${COMP_WORDS[1]}" == "vpn" ]]; then
        opts="connect disconnect status"
    else
        return 0
    fi

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
}

complete -F _work_completions work
