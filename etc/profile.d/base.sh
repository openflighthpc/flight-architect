################################################################################
##
## Alces Underware - Shell configuration
## Copyright (c) 2008-2015 Alces Software Ltd
##
################################################################################
underware() {
    # XXX Disabled for now as does not do anything for new Underware.
    # if [[ -t 1 && "$TERM" != linux ]]; then
    #     export alces_COLOUR=1
    # else
    #     export alces_COLOUR=0
    # fi
    (cd /opt/underware && PATH="/opt/underware/opt/ruby/bin:$PATH" bin/underware "$@")
    # unset alces_COLOUR
}

if [ "$ZSH_VERSION" ]; then
    export underware
else
    export -f underware
fi

if [ "$BASH_VERSION" ]; then
    _underware() {
        local cur="$2" cmds input cur_ruby

        if [[ -z "$cur" ]]; then
            cur_ruby="__CUR_IS_EMPTY__"
        else
            cur_ruby=$cur
        fi

        cmds=$(
            cd /opt/underware &&
            PATH="/opt/underware/opt/ruby/bin:$PATH"
            bin/autocomplete $cur_ruby ${COMP_WORDS[*]}
        )

        COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
    }
    complete -o default -F _underware underware
fi
