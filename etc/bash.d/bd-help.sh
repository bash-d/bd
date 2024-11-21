# bd-help.sh: display help for bd

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

# display help
_bd_help() {
    local bd_bits_dir="${BD_BITS_DIR:-${BD_DIR}/etc/bash.d/bits}"
    local bd_help=''
    bd_help+="usage: bd [option]\n"
    bd_help+="\n"
    bd_help+="options:\n"
    bd_help+="\n"
    bd_help+="  ['' | *]                            - (default) invoke autoloader\n"
    bd_help+="\n"
    bd_help+="  env [BD_* variable]                 - display BD_* environment variables & values, and optionally the value of a single variable\n"
    bd_help+="  dir [hash | ls]                     - display only BD_AUTOLOAD_DIRS array values, and optionally hash or list them\n"
    bd_help+="\n"
    bd_help+="  license                             - display MIT license\n"
    bd_help+="  version                             - display version\n"
    bd_help+="\n"
    bd_help+="  upgrade                             - upgrade bd; pull the latest version from "
    if [ ${#BD_GIT_URL} -gt 0 ]; then
        bd_help+="${BD_GIT_URL}"
    else
        bd_help+="GitHub"
    fi
    bd_help+="\n"
    bd_help+="\n"
    bd_help+="  bits get <url> [name]               - get a file from an <url> and put it in ${bd_bits_dir}/[name]\n"
    bd_help+="  bits [hash | ls]                    - display all (.bash & .sh) files in ${bd_bits_dir}\n"
    bd_help+="  bits rm <name>                      - remove bits named <name> from ${bd_bits_dir}\n"
    #bd_help+="  bits put <file>                     - get a file and put/upload it to <url>\n" # WIP
    bd_help+="\n"
    bd_help+="  functions                           - export public _bd_ functions but do not invoke autoloader\n"
    bd_help+="\n"
    bd_help+="  [help | h | --help | -h]            - this message\n"

    printf "${bd_help}"
}
