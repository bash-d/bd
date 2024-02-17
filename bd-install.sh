#!/usr/bin/env bash

# bd-install: bash-d/bd installer

# curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bin/bd-install | bash -s _ replace

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

export BD_INSTALL_GIT_URL=${BD_INSTALL_GIT_URL:-"https://githubusercontent.com/bash-d/bd/main/bin/bd-install"}

#
# init
#

# prevent sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is designed to be sourced\n\n"
    exit 1
fi

# display (cli) usage options
bd_install_usage() {
    printf "\nusage: ${BASH_SOURCE} <append|replace>\n\n"
}

#
# main
#

if [ "${USER}" == "root" ]; then
    echo "root/system installation is currently WIP; run ${0} as a normal user" && exit 1
fi

# curl -Ls file:///${BD_DIR}/bin/bd-install | bash -s _ replace

[ "${1}" == "_" ] && shift

[ "${1}" == "" ] && bd_install_usage && exit 99
[ "${1}" == "--help" ] && bd_install_usage && exit 99

BD_INSTALL_APPEND=0
BD_INSTALL_REPLACE=0

[ "${1}" == "append" ] && BD_INSTALL_APPEND=1
[ "${1}" == "replace" ] && BD_INSTALL_REPLACE=1

[ ${BD_INSTALL_APPEND} -eq 0 ] && [ ${BD_INSTALL_REPLACE} -eq 0 ] && bd_install_usage && exit 99

BD_INSTALL_REQUIRED=()
BD_INSTALL_REQUIRED+=("cp")
BD_INSTALL_REQUIRED+=("curl")
BD_INSTALL_REQUIRED+=("date")
BD_INSTALL_REQUIRED+=("diff")
BD_INSTALL_REQUIRED+=("git")
BD_INSTALL_REQUIRED+=("grep")
BD_INSTALL_REQUIRED+=("mkdir")

for BD_INSTALL_REQUIRE in ${BD_INSTALL_REQUIRED[@]}; do
    # ensure gnu dependency
    if ! type -P ${BD_INSTALL_REQUIRE} &> /dev/null; then
        echo "# [ERROR] ... '${BD_INSTALL_REQUIRE}' executable not found; install gnu ${BD_INSTALL_REQUIRE}" && exit 1
    fi

    # ensure gnu dependency works
    if ! ${BD_INSTALL_REQUIRE} --version 2>&1 | grep -q ^${BD_INSTALL_REQUIRE}; then
        echo "# [ERROR] ... '${BD_INSTALL_REQUIRE}' executable not working as expected" && exit 1
    fi
done
unset BD_INSTALL_REQUIRE unset BD_INSTALL_REQUIRED

[ ${#BD_DIR} -eq 0 ] && [ ${#BD_HOME} -gt 0 ] && export BD_DIR="${BD_HOME}/.bd"
export BD_DIR=${BD_DIR:-~/.bd}

BD_INSTALL_EXISTS=0
if [ -r "${BD_DIR}/bd.sh" ]; then
    BD_INSTALL_EXISTS=1
fi

echo
[ ! -d "${BD_DIR}" ] && mkdir -p "${BD_DIR}"
[ ! -d "${BD_DIR}" ] && echo "# [ERROR] ... '${BD_DIR}' directory not found" && echo && exit 1
[ ! -w "${BD_DIR}" ] && echo "# [ERROR] ... '${BD_DIR}' directory not writable" && echo && exit 1

echo "# [OK] ... '${BD_DIR}' directory found"
echo

export BD_GIT_URL=${BD_GIT_URL:-"https://github.com/bash-d/bd"}

if [ "${BD_INSTALL_EXISTS}" == "1" ]; then
    BD_INSTALL_PWD="${PWD}"
    cd "${BD_DIR}"
    git pull ${BD_DIR} &> /dev/null
    [ $? -ne 0 ] && echo "# [ERROR] ... 'git pull ${BD_DIR}' failed" && cd "${BD_INSTALL_PWD}" && exit 1
    cd "${BD_INSTALL_PWD}"
    unset -v BD_INSTALL_PWD
    echo "# [OK] ... '${BD_GIT_URL}' pulled"
else
    git clone ${BD_GIT_URL} ${BD_DIR} && echo
    [ $? -ne 0 ] && echo "# [ERROR] ... 'git clone ${BD_GIT_URL} ${BD_DIR}' failed" && exit 1
    echo "# [OK] ... '${BD_GIT_URL}' installed"
fi
echo

[ ! -r "${BD_DIR}/.bash_profile" ] && echo "# [ERROR] ... '${BD_DIR}/.bash_profile' file not found readable" && exit 1
[ ! -r "${BD_DIR}/.bashrc" ] && echo "# [ERROR] ... '${BD_DIR}/.bashrc' file not found readable" && exit 1

BD_INSTALL_TIMESTAMP="$(date +%y%m%d%H%M%S%z)" # posix

if [ "${BD_INSTALL_APPEND}" == "1" ]; then
    # append ~/.bash_profile
    if [ -f ~/.bash_profile ]; then
        BD_INSTALL_APPEND_BASH_PROFILE="$(grep -E -e ' (.|source) (.*)/.bashrc( |$|")' ~/.bash_profile 2> /dev/null)"
        if [ ${#BD_INSTALL_APPEND_BASH_PROFILE} -gt 0 ]; then
            echo "# [OK] ... '~/.bash_profile' sources '~/.bashrc'"
        else
            if [ -f ~/.bash_profile ]; then
                cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}
                [ $? -ne 0 ] && echo "# [ERROR] ... 'cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}' failed" && exit 1
                echo "# [OK] ...'~/.bash_profile.${BD_INSTALL_TIMESTAMP}' backed up"
                echo
            fi
            echo >> ~/.bash_profile
            echo '. ~/.bashrc' >> ~/.bash_profile
            [ $? -ne 0 ] && echo "# [ERROR] ... 'echo '. ~/.bashrc' >> ~/.bash_profile' failed" && exit 1
            echo "# [OK] ... '~/.bash_profile' appended"
        fi
        unset -v BD_INSTALL_APPEND_BASH_PROFILE
        echo
    fi

    # append ~/.bashrc
    if [ -f ~/.bashrc ]; then
        BD_INSTALL_APPEND_BASHRC="$(grep -E -e ' (.|source) (.*)/bd.sh( |$|")' ~/.bashrc) 2> /dev/null"
        if [ ${#BD_INSTALL_APPEND_BASHRC} -gt 0 ]; then
            echo "# [OK] ... '~/.bashrc' sources 'bd.sh'"
        else
            if [ -f ~/.bashrc ]; then
                cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}
                [ $? -ne 0 ] && echo "# [ERROR] ... 'cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}' failed" && exit 1
                echo "# [OK] ...'~/.bashrc.${BD_INSTALL_TIMESTAMP}' backed up"
                echo
            fi
            echo >> ~/.bashrc
            echo "source \"${BD_DIR}/bd.sh\" \${@}" >> ~/.bashrc
            [ $? -ne 0 ] && echo "# [ERROR] ... 'echo "source \"${BD_DIR}/bd.sh\" \${@}" >> ~/.bashrc' failed" && exit 1
            echo "# [OK] ... '~/.bashrc' appended"
        fi
        unset -v BD_INSTALL_APPEND_BASHRC
        echo
    fi
fi

if [ "${BD_INSTALL_REPLACE}" == "1" ]; then
    # replace ~/.bash_profile
    if ! diff -q ~/.bash_profile "${BD_DIR}/.bash_profile" &> /dev/null; then
        if [ -f ~/.bash_profile ]; then
            cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}
            [ $? -ne 0 ] && echo "# [ERROR] ... 'cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}' failed" && exit 1
            echo "# [OK] ...'~/.bash_profile.${BD_INSTALL_TIMESTAMP}' backed up"
            echo
        fi
        cp "${BD_DIR}/.bash_profile" ~/.bash_profile
        [ $? -ne 0 ] && echo "'cp ${BD_DIR}/.bash_profile ~/.bash_profile' failed" && exit 1
        echo "# [OK] ... '~/.bash_profile' replaced"
    else
        echo "# [OK] ... '~/.bash_profile' sources '~/.bashrc'"
    fi
    echo

    # replace ~/.bashrc
    if ! diff -q ~/.bashrc "${BD_DIR}/.bashrc" &> /dev/null; then
        if [ -f ~/.bashrc ]; then
            cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}
            [ $? -ne 0 ] && echo "# [ERROR] ... 'cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}' failed" && exit 1
            echo "# [OK] ...'~/.bashrc.${BD_INSTALL_TIMESTAMP}' backed up"
            echo
        fi
        cp "${BD_DIR}/.bashrc" ~/.bashrc
        [ $? -ne 0 ] && echo "'cp ${BD_DIR}/.bashrc ~/.bashrc' failed" && exit 1
        echo "# [OK] ... '~/.bashrc' replaced"
    else
        echo "# [OK] ... '~/.bashrc' sources 'bd.sh'"
    fi
    echo
fi

exit $?
