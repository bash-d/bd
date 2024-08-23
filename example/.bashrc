# .bashrc is executed for non-login shells, e.g. every time a terminal is opened

#
# do not execute
#

[ "${BASH_SOURCE}" == "${0}" ] && exit

#
# returns for non-interactive shells
#

case $- in
    *i*)
        # interactive shell (OK)
        ;;
    *)
        # stop. non-interactive shell
        return
        ;;
esac

if [ ${#PS1} -le 0 ]; then
    # stop. no prompt
    return
fi

if [ ${#SSH_CONNECTION} -gt 0 ] && [ ${#SSH_TTY} -eq 0 ] && [ ${#STY} -eq 0 ] && [ ${#TMUX} -eq 0 ] && [ ${#VSCODE_GIT_IPC_HANDLE} -eq 0 ]; then
    # stop. ssh (scp/sftp), no tty, no screen, no tmux, no vscode
    return
fi

#
# source system bashrc
#

[ -f /etc/bashrc ] && source /etc/bashrc

#
# bash.d (0.40+)
#

export BD_DEBUG=0

if [ "${USER}" == "root" ]; then
    # support root (sudo) & bd-root aliases

    [ ${#BD_HOME} -gt 0 ] && [ -r "${BD_HOME}/.bd" ] && export BD_DIR="${BD_HOME}/.bd" && [ -r ${BD_DIR}/bd.sh ] && source ${BD_DIR}/bd.sh ${@}
else
    # support normal user

    export BD_DIR=~/.bd
    export BD_GIT_URL=${BD_GIT_URL:-"https://github.com/bash-d/bd"}

    # if bd.sh is not found, try to automatically install bd
    if [ ${#BD_DIR} -gt 0 ] && [ ! -r "${BD_DIR}/bd.sh" ]; then
        git clone "${BD_GIT_URL}" "${BD_DIR}" &> /dev/null
    fi

    if [ ${#BD_DIR} -gt 0 ] && [ -r "${BD_DIR}/bd.sh" ]; then
        source "${BD_DIR}/bd.sh" ${@}
    else
        printf "\n${BD_DIR}/bd.sh file not found readable (install git & run 'cd && git clone ${BD_GIT_URL} ${BD_DIR}')\n\n"
    fi
fi
