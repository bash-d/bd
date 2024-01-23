# bd-root.sh: appropriately add bd-root and bd-root-login aliases to a shell's environment

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

#
# init
#

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

#
# main
#

if [ "${USER}" != "root" ]; then
    # bash & sudo must be in the default path
    [ ${#BD_ROOT_BASH_BIN} -eq 0 ] && export BD_ROOT_BASH_BIN="$(type -P bash 2> /dev/null)"
    [ ${#BD_ROOT_BASH_BIN} -eq 0 ] && unset -v BD_ROOT_BASH_BIN

    [ ${#BD_ROOT_SU_BIN} -eq 0 ] && export BD_ROOT_SU_BIN="$(type -P su 2> /dev/null)"
    [ ${#BD_ROOT_SU_BIN} -eq 0 ] && unset -v BD_ROOT_SU_BIN

    [ ${#BD_ROOT_SUDO_BIN} -eq 0 ] && export BD_ROOT_SUDO_BIN="$(type -P sudo 2> /dev/null)"
    [ ${#BD_ROOT_SUDO_BIN} -eq 0 ] && unset -v BD_ROOT_SUDO_BIN

    if [ ${#BD_ROOT_BASH_BIN} -gt 0 ] && [ -x "${BD_ROOT_BASH_BIN}" ]; then
        # bash init file must be readable
        if [ "${BD_BASH_INIT_FILE}" != "" ] && [ -r "${BD_BASH_INIT_FILE}" ]; then
            if [ ${#BD_ROOT_SUDO_BIN} -gt 0 ] && [ -x "${BD_ROOT_SUDO_BIN}" ]; then
                export BD_ROOT_SUDO_NOPASSWD=0

                if (${BD_ROOT_SUDO_BIN} -vn && ${BD_ROOT_SUDO_BIN} -ln) 2>&1 | grep -qv 'may not' &> /dev/null; then
                    BD_ROOT_SUDO_NOPASSWD=1
                fi

                export BD_ROOT_SUDO_MUST_PRESERVE_ENV="BD_HOME,BD_USER"
                [ "${BD_ROOT_SUDO_PRESERVE_ENV}" != "" ] && BD_ROOT_SUDO_MUST_PRESERVE_ENV+=",${BD_ROOT_SUDO_PRESERVE_ENV}"
                [[ "${BD_ROOT_SUDO_MUST_PRESERVE_ENV}" != *",SSH_AUTH_SOCK"* ]] && [ "${SSH_AUTH_SOCK}" != "" ] && BD_ROOT_SUDO_MUST_PRESERVE_ENV+=",SSH_AUTH_SOCK"

                BD_ROOT_SUDO_MUST_PRESERVE_ENV="${BD_ROOT_SUDO_MUST_PRESERVE_ENV//,,/,}"

                alias bd-root="${BD_ROOT_SUDO_BIN} --preserve-env=${BD_ROOT_SUDO_MUST_PRESERVE_ENV} -u root ${BD_ROOT_BASH_BIN} --init-file ${BD_BASH_INIT_FILE}"
                alias bd-root-login="${BD_ROOT_SUDO_BIN} --preserve-env=${BD_ROOT_SUDO_MUST_PRESERVE_ENV} -u root --login"

                unset -v BD_ROOT_SUDO_MUST_PRESERVE_ENV
            else
                if [ ${#BD_ROOT_SU_BIN} -gt 0 ] && [ -x "${BD_ROOT_SU_BIN}" ]; then
                    alias bd-root="su --login root -c '${BD_ROOT_BASH_BIN} --init-file ${BD_BASH_INIT_FILE}'"
                    alias bd-root-login='su --login'
                fi
            fi
        fi
    fi
else
    alias bd-root='source "${BD_BASH_INIT_FILE}"'
    alias bd-root-login=bd-root
fi
