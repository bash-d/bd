# bd-sundry.sh: bd miscellaneous

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

# sundry options
_bd_sundry() {
    _bd_debug "${FUNCNAME} ${@}" 55

    if [[ "${1}" == "dir"* ]] || [ "${1}" == "autoload_dirs" ]; then
        _bd_autoload_dirs ${@}
    fi

    if [[ "${1}" == "env"* ]]; then
        _bd_environment ${@}
    fi

    if [[ "${1}" == "vers"* ]]; then
        echo "${BD_VERSION}"
    fi
}

# info BD_AUTOLOADER_DIRS array
_bd_autoload_dirs() {
    _bd_debug "${FUNCNAME}(${@})" 55

    if [ ${#2} -gt 0 ]; then
        if [ "${2}" == 'hash' ] || [ "${2}" == 'ls' ]; then
            local bd_autoload_dir bd_autoload_file
            for bd_autoload_dir in "${BD_AUTOLOAD_DIRS[@]}"; do
                if [ -d "${bd_autoload_dir}" ]; then
                    echo "# ${bd_autoload_dir}"
                    echo
                    for bd_autoload_file in "${bd_autoload_dir}"/*.{bash,sh}; do
                        if [ -r "${bd_autoload_file}" ]; then
                            _bd_debug "bd_autoload_file=${bd_autoload_file}" 18
                            if [ "${2}" == 'hash' ]; then
                                command md5sum "${bd_autoload_file}"
                            fi
                            if [ "${2}" == 'ls' ]; then
                                command ls -1d "${bd_autoload_file}"
                            fi
                        fi
                    done
                    echo
                fi
            done
            return 0
        fi
    fi

    echo "${BD_AUTOLOAD_DIRS[@]}"
}

# env option
_bd_environment() {
    _bd_debug "${FUNCNAME}(${@})" 55

    if [ ${#2} -gt 0 ]; then
        if [ "${!2}" != '' ]; then
            echo "${2}=${!2}"
            return 0
        fi
    fi

    _bd_load_config preload

    local bd_declare bd_variable_name
    local bd_oifs="${IFS}"

    IFS=$'\n'
    for bd_declare in $(declare -g 2> /dev/null); do
        if [[ "${bd_declare}" == 'BD_'*'='* ]]; then
            bd_variable_name="${bd_declare%%=*}"

            # don't show these
            _bd_private "${bd_variable_name}" && continue

            printf "%-30s" "${bd_variable_name}"
            printf " = "
            if [ "${bd_variable_name}" == 'BD_AUTOLOAD_DIRS' ]; then
                echo "${BD_AUTOLOAD_DIRS[@]}"
            else
                echo "${!bd_variable_name}"
            fi
        fi
    done
    IFS="${bd_oifs}"
}
