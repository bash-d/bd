# bd-install.sh: bd bits (wip)

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


# bits option
_bd_bits() {
    _bd_debug "${FUNCNAME} ${@}" 1

    local bd_required_executable
    local bd_required_executables=(curl ls rm)

    for bd_required_executable in ${bd_required_executables[@]}; do
        if ! type -P ${bd_required_executable} &> /dev/null; then
            echo "${bd_required_executable} not found executable"
            return 1
        fi
    done

    if [ -a "${BD_BITS_DIR}" ] && [ ! -d "${BD_BITS_DIR}" ]; then
        echo "\"${BD_BITS_DIR}\" is not a directory"
        return 1
    fi

    if [ ! -d "${BD_BITS_DIR}" ]; then
        mkdir -p "${BD_BITS_DIR}"
        if [ $? -ne 0 ]; then
            echo "failed to 'mkdir \"${BD_BITS_DIR}\"'"
            return 1
        fi
    fi

    if [ "${2}" == "get" ]; then
        if [ "${3}" == '' ]; then
            _bd_help
            return 1
        else
            _bd_bits_get ${@}
            return $?
        fi
    fi

    if [ "${2}" == "hash" ]; then
        _bd_bits_hash ${@}
        return $?
    fi

    if [ "${2}" == "" ] || [ "${2}" == "list" ] || [ "${2}" == "ls" ]; then
        _bd_bits_list ${@}
        return $?
    fi

    if [ "${2}" == "remove" ] || [ "${2}" == "rm" ]; then
        _bd_bits_remove ${@}
        return $?
    fi
}

# bits get
_bd_bits_get() {
    _bd_debug "${FUNCNAME} ${@}" 1

    _bd_load_config preload

    local bd_bits_get_from="${3}"
    local bd_bits_get_to="${4}"


    #bd_realpath_dirname="${bd_realpath_arg%/*}"

    local bd_bits_get_basename="${bd_bits_get_from##*/}"
    bd_bits_get_basename="${bd_bits_get_basename%\?*}" # no url parameters, e.g. github private links
    bd_bits_get_basename="${bd_bits_get_basename%\&*}" # no url parameters, e.g. github private links

    if [ -z "${bd_bits_get_to}" ]; then
        bd_bits_get_to="${bd_bits_get_basename:(-3)}"
        if [ "${bd_bits_get_to}" == ".sh" ]; then
            bd_bits_get_to="${bd_bits_get_basename}"
        else
            bd_bits_get_to="${bd_bits_get_basename:(-5)}"
            if [ "${bd_bits_get_to}" == ".bash" ]; then
                bd_bits_get_to="${bd_bits_get_basename}"
            else
                bd_bits_get_to="${bd_bits_get_basename}.sh"
            fi
        fi
    fi

    local bd_bits_get_install_file="${BD_BITS_DIR}/${bd_bits_get_to}"

    # replace it or quit
    if [ -a "${bd_bits_get_install_file}" ]; then
        echo -n "replace \"${bd_bits_get_install_file}\" (y/n) ? "
        read BD_YN
        if [ "${BD_YN:0:1}" != "y" ] && [ "${BD_YN:0:1}" != "Y" ]; then
            return 0
        else
            echo
            echo "replacing \"${bd_bits_get_install_file}\" ..."
            echo
            command -p rm "${bd_bits_get_install_file}"
            if [ $? -ne 0 ]; then
                echo "failed to 'command -p rm \"${bd_bits_get_install_file}\"'"
                return 1
            fi
        fi
    fi

    BD_CURL_ARGS="--silent"

    # get it
    echo curl ${BD_CURL_ARGS} ${bd_bits_get_from} -o ${bd_bits_get_install_file}
    command -p curl ${BD_CURL_ARGS} ${bd_bits_get_from} -o ${bd_bits_get_install_file}
    if [ $? -ne 0 ]; then
        echo "failed to 'curl ${BD_CURL_ARGS} ${bd_bits_get_from} -o ${bd_bits_get_install_file}'"
        return 1
    fi

    echo
    echo "--cut--"
    command -p cat ${bd_bits_get_install_file}
    echo "--cut--"
    echo

    echo -n "source \"${bd_bits_get_install_file}\" (y/n) ? "
    read BD_YN
    if [ "${BD_YN:0:1}" != "y" ] && [ "${BD_YN:0:1}" != "Y" ]; then
        echo
        echo "removing \"${bd_bits_get_install_file}\""
        echo
        command -p rm "${bd_bits_get_install_file}"
        if [ $? -ne 0 ]; then
            echo "failed to 'command -p rm \"${bd_bits_get_install_file}\"'"
        fi
        return 1
    else
        echo
        echo "installed \"${bd_bits_get_install_file}\""
        echo . "${bd_bits_get_install_file}"
        . "${bd_bits_get_install_file}"
    fi
}

# bits hash
_bd_bits_hash() {
    echo "${BD_BITS_DIR}"

    echo
    local bd_autoloader_dir bd_autoloader_file
    for bd_autoloader_file in "${BD_BITS_DIR}"/*.{bash,sh}; do
        if [ -r "${bd_autoloader_file}" ]; then
            command md5sum "${bd_autoloader_file}"
        fi
    done
    echo

    return 0
}

# bits list
_bd_bits_list() {
    echo "${BD_BITS_DIR}"

    echo
    command ls -l "${BD_BITS_DIR}"
    echo

    return 0
}

# bits remove
_bd_bits_remove() {
    if [ "${3}" != "" ]; then
        if [ -f "${BD_BITS_DIR}/${3}" ]; then
            if [ -w "${BD_BITS_DIR}/${3}" ]; then
                command rm -i "${BD_BITS_DIR}/${3}"
                return $?
            else
                if [ -r "${BD_BITS_DIR}/${3}" ]; then
                    echo "'${BD_BITS_DIR}/${3}' file found readable (but not writable)"
                    return 1
                else
                    echo "'${BD_BITS_DIR}/${3}' file not found readable"
                    return 1
                fi
            fi
        else
            echo "'${BD_BITS_DIR}/${3}' file not found"
            return 1
        fi
    fi
    return 0
}
