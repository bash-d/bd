# bd-upgrade.sh: upgrade bd (wip)

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

# upgrade option
_bd_upgrade() {
    _bd_debug "${FUNCNAME}(${@})" 55

    [ ! -O "${BD_SOURCE}" ] && printf "\nrun 'bd ${1}' as the owner of ${BD_SOURCE} ...\n\n" && ls -l "${BD_SOURCE}" && echo && return 1

    local bd_upgrade_dir_name="${1}"

    if type -P git &> /dev/null; then
        _bd_load_config preload

        if [ -d "${bd_upgrade_dir_name}" ] && [ -r "${bd_upgrade_dir_name}" ]; then
            [ "${bd_upgrade_dir_name}" == "${BD_DIR}" ] && echo "BD_DIR = ${BD_DIR}" && echo

            local bd_upgrade_pwd="${PWD}"

            cd "${bd_upgrade_dir_name}"

            if [ -d .git ] && [ -r .git ]; then
                git remote -v && echo && git pull
            fi

            cd "${bd_upgrade_pwd}"

            unset -v bd_upgrade_pwd
        fi
    else
        echo; echo 'git not found'; echo
    fi
}
