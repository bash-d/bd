# bd-install.sh: bash-d installer

# MIT License
# ===========
#
# Copyright (C) 2018-2024 Joseph Tingiris <joseph.tingiris@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# https://github.com/bash-d/bd/blob/main/LICENSE.md

# usage examples
#
# cd; curl -Ls file:///${BD_DIR}/bd-install.sh | /usr/bin/env bash -s _ replace; . .bash_profile; bd env
# cd; curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | /usr/bin/env bash -s _ replace; . .bash_profile; bd env
# cd; curl -Ls https://raw.githubusercontent.com/bash-d/bd/refs/tags/v0.45.1/bd-install.sh | BD_INSTALL_RELEASE=v0.45.1 /usr/bin/env bash -s _ replace; . .bash_profile; bd env

#
# init
#

[ "${BASH_VERSION}" == "" ] && echo "bash is required" && exit 1

export BD_INSTALL_RELEASE=${BD_INSTALL_RELEASE:-'main'}

export BD_GIT_URL="https://github.com/bash-d/bd/"

# prevent execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (try '. ${BASH_SOURCE}')\n\n"
    exit 1
fi

# display (cli) usage options
_bd_install_usage() {
    printf "\nusage: ${BASH_SOURCE} <append|replace>\n\n"

    # sourcing via curl requires an exit
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "main" ]; then
        exit 99
    fi
}

#
# main
#

if [ "${USER}" == "root" ]; then
    echo "root/system installation is currently WIP; please run ${0} as a normal user"
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "main" ]; then
        exit 1
    else
        return 1
    fi
fi

[ "${1}" == "_" ] && shift

[ "${1}" == "" ] && _bd_install_usage && return 99
[ "${1}" == "--help" ] && _bd_install_usage && return 99

BD_INSTALL_APPEND=0
BD_INSTALL_REPLACE=0

[ "${1}" == "append" ] && BD_INSTALL_APPEND=1
[ "${1}" == "replace" ] && BD_INSTALL_REPLACE=1

[ ${BD_INSTALL_APPEND} -eq 0 ] && [ ${BD_INSTALL_REPLACE} -eq 0 ] && _bd_install_usage && return 99

BD_INSTALL_REQUIRED=()
BD_INSTALL_REQUIRED+=("cp")
BD_INSTALL_REQUIRED+=("curl")
BD_INSTALL_REQUIRED+=("date")
BD_INSTALL_REQUIRED+=("diff")
BD_INSTALL_REQUIRED+=("git")
BD_INSTALL_REQUIRED+=("grep")
BD_INSTALL_REQUIRED+=("mkdir")

for BD_INSTALL_REQUIRE in ${BD_INSTALL_REQUIRED[@]}; do
    # ensure dependency
    if ! type -P ${BD_INSTALL_REQUIRE} &> /dev/null; then
        echo "# [ERROR] ... '${BD_INSTALL_REQUIRE}' executable not found; install ${BD_INSTALL_REQUIRE}"
        if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
            exit 1
        else
            return 1
        fi
    fi

    # ensure dependency works
    if ! ${BD_INSTALL_REQUIRE} --version 2>&1 | grep -q ^${BD_INSTALL_REQUIRE}; then
        echo "# [ERROR] ... '${BD_INSTALL_REQUIRE}' executable not working as expected"
        if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
            exit 1
        else
            return 1
        fi
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
if [ ! -d "${BD_DIR}" ]; then
    echo "# [ERROR] ... '${BD_DIR}' directory not found" && echo
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
        exit 1
    else
        return 1
    fi
fi

if [ ! -w "${BD_DIR}" ]; then
    echo "# [ERROR] ... '${BD_DIR}' directory not writable" && echo
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
        exit 1
    else
        return 1
    fi
fi

echo "# [OK] ... '${BD_DIR}' directory found"
echo


if [ "${BD_INSTALL_EXISTS}" == "1" ]; then
    BD_INSTALL_PWD="${PWD}"
    cd "${BD_DIR}"

    git pull ${BD_DIR} &> /dev/null
    if [ $? -ne 0 ]; then
        echo "# [ERROR] ... 'git pull ${BD_DIR}' failed" && cd "${BD_INSTALL_PWD}"
        if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
            exit 1
        else
            return 1
        fi
    fi

    cd "${BD_INSTALL_PWD}"
    unset -v BD_INSTALL_PWD

    echo "# [OK] ... 'git pull ${BD_DIR} ' pulled"
else
    echo "# [OK] git clone --depth 1 --branch ${BD_INSTALL_RELEASE} ${BD_GIT_URL} ${BD_DIR}" && echo
    git clone --depth 1 --branch ${BD_INSTALL_RELEASE} ${BD_GIT_URL} ${BD_DIR} && echo
    if [ $? -ne 0 ]; then
        echo "# [ERROR] ... 'git clone --depth 1 --branch ${BD_INSTALL_RELEASE} ${BD_GIT_URL} ${BD_DIR}' failed"
        if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
            exit 1
        else
            return 1
        fi
    fi

    echo "# [OK] ... '${BD_GIT_URL}tree/${BD_INSTALL_RELEASE}' installed"
fi
echo

if [ ! -r "${BD_DIR}/example/.bash_profile" ]; then
    echo "# [ERROR] ... '${BD_DIR}/example/.bash_profile' file not found readable"
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
        exit 1
    else
        return 1
    fi
fi

if [ ! -r "${BD_DIR}/example/.bashrc" ]; then
    echo "# [ERROR] ... '${BD_DIR}/example/.bashrc' file not found readable"
    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
        exit 1
    else
        return 1
    fi
fi

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
                if [ $? -ne 0 ]; then
                    echo "# [ERROR] ... 'cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}' failed"
                    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                        exit 1
                    else
                        return 1
                    fi
                fi

                echo "# [OK] ...'~/.bash_profile.${BD_INSTALL_TIMESTAMP}' backed up"
                echo
            fi

            echo >> ~/.bash_profile
            echo '. ~/.bashrc' >> ~/.bash_profile
            if [ $? -ne 0 ]; then
                echo "# [ERROR] ... 'echo '. ~/.bashrc' >> ~/.bash_profile' failed"
                if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                    exit 1
                else
                    return 1
                fi
            fi

            echo "# [OK] ... '~/.bash_profile' appended"
        fi
        unset -v BD_INSTALL_APPEND_BASH_PROFILE
        echo
    fi

    # append ~/.bashrc
    if [ -f ~/.bashrc ]; then
	BD_INSTALL_APPEND_BASHRC="$(grep -E -e '(.|source) (.*)/bd.sh( |$|")' ~/.bashrc 2> /dev/null)"
        if [ ${#BD_INSTALL_APPEND_BASHRC} -gt 0 ]; then
            echo "# [OK] ... '~/.bashrc' sources 'bd.sh'"
        else
            if [ -f ~/.bashrc ]; then
                cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}
                if [ $? -ne 0 ]; then
                    echo "# [ERROR] ... 'cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}' failed"
                    if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                        exit 1
                    else
                        return 1
                    fi
                fi

                echo "# [OK] ...'~/.bashrc.${BD_INSTALL_TIMESTAMP}' backed up"
                echo
            fi

            echo >> ~/.bashrc
            echo ". \"${BD_DIR}/bd.sh\" \${@}" >> ~/.bashrc
            if [ $? -ne 0 ]; then
                echo "# [ERROR] ... 'echo ". \"${BD_DIR}/bd.sh\" \${@}" >> ~/.bashrc' failed"
                if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                    exit 1
                else
                    return 1
                fi
            fi

            echo "# [OK] ... '~/.bashrc' appended"
        fi
        unset -v BD_INSTALL_APPEND_BASHRC
        echo
    fi
fi

if [ "${BD_INSTALL_REPLACE}" == "1" ]; then
    # replace ~/.bash_profile
    if ! diff -q ~/.bash_profile "${BD_DIR}/example/.bash_profile" &> /dev/null; then
        if [ -f ~/.bash_profile ]; then
            cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}
            if [ $? -ne 0 ]; then
                echo "# [ERROR] ... 'cp ~/.bash_profile ~/.bash_profile.${BD_INSTALL_TIMESTAMP}' failed"
                if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                    exit 1
                else
                    return 1
                fi
            fi

            echo "# [OK] ...'~/.bash_profile.${BD_INSTALL_TIMESTAMP}' backed up"
            echo
        fi

        cp "${BD_DIR}/example/.bash_profile" ~/.bash_profile
        if [ $? -ne 0 ]; then
            echo "'cp ${BD_DIR}/example/.bash_profile ~/.bash_profile' failed"
            if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                exit 1
            else
                return 1
            fi
        fi

        echo "# [OK] ... '~/.bash_profile' replaced"
    else
        echo "# [OK] ... '~/.bash_profile' sources '~/.bashrc'"
    fi
    echo

    # replace ~/.bashrc
    if ! diff -q ~/.bashrc "${BD_DIR}/example/.bashrc" &> /dev/null; then
        if [ -f ~/.bashrc ]; then
            cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}
            if [ $? -ne 0 ]; then
                echo "# [ERROR] ... 'cp ~/.bashrc ~/.bashrc.${BD_INSTALL_TIMESTAMP}' failed"
                if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                    exit 1
                else
                    return 1
                fi
            fi

            echo "# [OK] ...'~/.bashrc.${BD_INSTALL_TIMESTAMP}' backed up"
            echo
        fi

        cp "${BD_DIR}/example/.bashrc" ~/.bashrc
        if [ $? -ne 0 ]; then
            echo "'cp ${BD_DIR}/example/.bashrc ~/.bashrc' failed"
            if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
                exit 1
            else
                return 1
            fi
        fi

        echo "# [OK] ... '~/.bashrc' replaced"
    else
        echo "# [OK] ... '~/.bashrc' sources 'bd.sh'"
    fi
    echo
fi

if [ "${0}" == "bash" ] && [ "${BASH_SOURCE}" == "" ]; then
    exit $?
else
    . ~/.bash_profile
    return $?
fi
