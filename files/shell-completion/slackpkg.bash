# bash completion for slackpkg(8)                          -*- shell-script -*-
# options list is based on `grep '\-.*\=.*)' /usr/sbin/slackpkg | cut -f1 -d\)`

_slackpkg()
{
    local cur prev words cword
    _init_completion -n = || return

    local split=false
    if [[ $cur == -?*=* ]]; then
        prev="${cur%%?(\\)=*}"
        cur="${cur#*=}"
        split=true
    fi

    case "$prev" in
        -delall | -checkmd5 | -checkgpg | -checksize | -postinst | -onoff | \
            -download_all | -dialog | -batch | -only_new_dotnew | \
            -use_includes | -spinning)
            COMPREPLY=($(compgen -W 'on off' -- "$cur"))
            return
            ;;
        -default_answer)
            COMPREPLY=($(compgen -W 'yes no' -- "$cur"))
            return
            ;;
        -dialog_maxargs | -mirror)
            # argument required but no completions available
            return
            ;;
    esac

    $split && return

    if [[ $cur == -* ]]; then
        compopt -o nospace
        COMPREPLY=($(compgen -W '-delall= -checkmd5= -checkgpg=
            -checksize= -postinst= -onoff= -download_all= -dialog=
            -dialog_maxargs= -batch= -only_new_dotnew= -use_includes=
            -spinning= -default_answer= -mirror=' -- "$cur"))
        return
    fi

    local confdir="/etc/slackpkg"
    local config="$confdir/slackpkg.conf"

    [[ -r $config ]] || return
    . "$config"

    local i action
    for ((i = 1; i < ${#words[@]}; i++)); do
        if [[ ${words[i]} != -* ]]; then
            action="${words[i]}"
            break
        fi
    done

    case "$action" in
        generate-template | search | file-search)
            # argument required but no completions available
            return
            ;;
        install-template | remove-template)
            if [[ -e $confdir/templates ]]; then
                COMPREPLY=($(
                    command cd -- "$confdir/templates"
                    compgen -f -X "!*.template" -- "$cur"
                ))
                COMPREPLY=(${COMPREPLY[@]%.template})
            fi
            return
            ;;
        remove)
            _filedir
            COMPREPLY+=($(compgen -W 'a ap d e f k kde kdei l n t tcl x
                xap xfce y' -- "$cur"))
            COMPREPLY+=($(
                command cd /var/log/packages
                compgen -f -- "$cur"
            ))
            return
            ;;
        install | reinstall | upgrade | blacklist | download)
            _filedir
            COMPREPLY+=($(compgen -W 'a ap d e f k kde kdei l n t tcl x
                xap xfce y' -- "$cur"))
            COMPREPLY+=($(cut -f 6 -d\  "${WORKDIR}/pkglist" 2>/dev/null |
                command grep "^$cur"))
            return
            ;;
        info)
            COMPREPLY=($(cut -f 6 -d\  "${WORKDIR}/pkglist" 2>/dev/null |
                command grep "^$cur"))
            return
            ;;
        update)
            # we should complete the same as the next `list` + "gpg"
            COMPREPLY=($(compgen -W 'gpg' -- "$cur"))
            ;&
        *)
            COMPREPLY+=($(compgen -W 'install reinstall upgrade remove
                blacklist download update install-new upgrade-all
                clean-system new-config check-updates help generate-template
                install-template remove-template search file-search info
                show-changelog' -- \
                "$cur"))
            return
            ;;
    esac

} &&
    complete -F _slackpkg slackpkg

# ex: filetype=sh
