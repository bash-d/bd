# bd.sh: bash directory (bash.d) autoloader

# https://github.com/bash-d/bd/blob/main/README.md

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

# prevent execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (try '. ${BASH_SOURCE}')\n\n"
    exit 1
fi

# prevent non-bash bourne compatible shells
if [ "${BASH_SOURCE}" == '' ]; then
    return 1 &> /dev/null
fi

export BD_VERSION=0.46.1

#
# functions
#

# mimic ksh/zsh autoload builtin
autoload() {
    _bd_autoload ${@}
}
export -f autoload

# primary functional interfce for this script
bd() {
    [ -r "${BD_SOURCE}" ] && . "${BD_SOURCE}" ${@}
}
export -f bd

# stub _bd_ansi() until bd-ansi.sh is fully loaded (needed for embedded _bd_debug)
if ! type -t _bd_ansi &> /dev/null; then
    if [ -r "${BD_DIR}/${BD_SUB_DIR}/bd-ansi.sh" ]; then
        . "${BD_DIR}/${BD_SUB_DIR}/bd-ansi.sh"
    else
        _bd_ansi() {
            return
        }
        export -f _bd_ansi
    fi
fi

# mimic ksh/zsh function autoload
_bd_autoload() {
    ''
}

# start the autoloader procedure
_bd_autoloader() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_start_arg="${1}"
    [ ${#bd_start_arg} -gt 0 ] && _bd_debug "bd_start_arg=${bd_start_arg}" 2

    # initialize a new namespace

    _bd_namespace_init

    # conditionally unset bd() function

    if [ ${#BD_SOURCE} -eq 0 ] || [ ! -r "${BD_SOURCE}" ]; then
        unset -f bd
        return 1
    fi

    # directory autoloader array

    _bd_autoloader_execute_array "${BD_AUTOLOADER_DIRS[@]}"

    return $?
}
export -f _bd_autoloader

# add only unique, existing directories to the BD_AUTOLOADER_DIRS array (& prevent dupes & preserve the given order)
_bd_autoloader_dir() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_dir_name="${1//\/\//\/}"

    bd_dir_name="${bd_dir_name//\/\//\/}"
    bd_dir_name="${bd_dir_name//\/\//\/}"

    _bd_debug "1 bd_dir_name = ${bd_dir_name}" 6

    [ ${#bd_dir_name} -eq 0 ] && return 1

    [ ! -d "${bd_dir_name}" ] && return 1

    bd_dir_name="$(_bd_realpath "${bd_dir_name}")"

    _bd_debug "2 bd_dir_name = ${bd_dir_name}" 6

    [ ${#BD_AUTOLOADER_DIRS} -eq 0 ] && export BD_AUTOLOADER_DIRS=()

    local bd_dir_exists=0 # false
    local bd_autoloader_dir

    for bd_autoloader_dir in ${BD_AUTOLOADER_DIRS[@]}; do
        [ ${bd_dir_exists} -eq 1 ] && break
        [ "${bd_autoloader_dir}" == "${bd_dir_name}" ] && bd_dir_exists=1
    done

    [ ${bd_dir_exists} -eq 0 ] && BD_AUTOLOADER_DIRS+=("${bd_dir_name}") && _bd_debug "bd_dir_name = ${bd_dir_name}" 2
}
export -f _bd_autoloader_dir

# predictably execute commands from every (.bash or .sh) file into the current shell
_bd_autoloader_execute() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_autoloader_execute_dir="${1}"

    if [ -d "${bd_autoloader_execute_dir}" ] && [ -r "${bd_autoloader_execute_dir}" ]; then
        local bd_autoloader_execute_file
        local bd_autoloader_execute_files=()

        # LC_COLLATE consistency hack (due to bsd/darwin differences)
        # https://collation-charts.org/fbsd54/

        local bd_autoloader_execute_collate="${LC_COLLATE}"

        LC_COLLATE=POSIX # required for consistent collation across operating systems
        for bd_autoloader_execute_file in "${bd_autoloader_execute_dir}"/*\.{bash,sh}; do
            bd_autoloader_execute_files+=("${bd_autoloader_execute_file}")
        done

        [ ${#bd_autoloader_execute_collate} -gt 0 ] && LC_COLLATE="${bd_autoloader_execute_collate}" || unset -v LC_COLLATE

        for bd_autoloader_execute_file in "${bd_autoloader_execute_files[@]}"; do

            if [ "${bd_autoloader_execute_file}" == "${BD_SOURCE}" ]; then
                # relative location
                _bd_debug "${FUNCNAME} ${bd_autoloader_execute_file} matches relative path" 13
                continue
            fi

            if [ "${bd_autoloader_execute_file}" == "${BD_SOURCE##*/}" ]; then
                # basename
                _bd_debug "${FUNCNAME}) ${bd_autoloader_execute_file} matches basename" 13
                continue
            fi

            if [ -r "${bd_autoloader_execute_file}" ]; then
                local bd_autoloader_execute_begin_time

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    bd_autoloader_execute_begin_time=$(_bd_uptime)
                fi

                _bd_debug "source  ${bd_autoloader_execute_file} ..." 4

                # execute commands in the current shell
                . "${bd_autoloader_execute_file}" '' # pass an empty arg to ${1}

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_autoloader_execute_end_time bd_autoloader_execute_total_time bd_autoloader_execute_total_ms

                    bd_autoloader_execute_end_time=$(_bd_uptime)
                    bd_autoloader_execute_total_time=$((${bd_autoloader_execute_end_time}-${bd_autoloader_execute_begin_time}))
                    bd_autoloader_execute_total_ms=$(_bd_debug_ms ${bd_autoloader_execute_total_time})
                    _bd_debug "sourced ${bd_autoloader_execute_file} ${bd_autoloader_execute_total_ms}" 3
                fi
            fi
        done
    fi
}
export -f _bd_autoloader_execute

# call _bd_autoloader_execute on an array (of directories)
_bd_autoloader_execute_array() {
    _bd_debug "${FUNCNAME}(${@})" 55

    [ ${#1} -eq 0 ] && return 1

    local bd_autoloader_dir_name bd_autoloader_finish bd_autoloader_start bd_autoloader_total bd_autoloader_total_ms

    for bd_autoloader_dir_name  in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_autoloader_start=$(_bd_uptime)

        _bd_autoloader_execute "${bd_autoloader_dir_name}"

        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_autoloader_finish=$(_bd_uptime)
            bd_autoloader_total=$((${bd_autoloader_finish}-${bd_autoloader_start}))
            bd_autoloader_total_ms="$(_bd_debug_ms ${bd_autoloader_total})"
            _bd_debug "_bd_autoloader_execute ${bd_autoloader_dir_name} ${bd_autoloader_total_ms}"
        fi
    done
}
export -f _bd_autoloader_execute_array

# prepare bash environment for bd
_bd_bootstrap() {
    _bd_caller || return 1

    export BD_CONFIG_FILE='.bd.conf'
    export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging
    export BD_SOURCE="$(_bd_realpath "${BASH_SOURCE}")"

    export BD_SUB_DIR="${BD_SUB_DIR:-etc/bash.d}"
    export BD_BITS_DIR="${BD_BITS_DIR:-${BD_DIR}/${BD_SUB_DIR}/bits}"

    _bd_debug "BD_SOURCE = ${BD_SOURCE} (${FUNCNAME})" 2

    export BD_DIR="${BD_SOURCE%/*}"

    _bd_debug "BD_DIR = ${BD_DIR} (${FUNCNAME})" 2
}
export -f _bd_bootstrap

# prevent excessive callers
_bd_caller() {
    local bd_callers=$((${#BASH_ARGC[@]}-1))
    local bd_callers_max=3

    if [ ${bd_callers} -gt ${bd_callers_max} ]; then
        _bd_debug "BASH_ARGC = ${BASH_ARGC[@]} (${#BASH_ARGC[@]})" 2
        _bd_debug "bd_callers = ${bd_callers} (>${bd_callers_max})" 2

        return 1
    fi
}
export -f _bd_caller

# consistent debug output
_bd_debug() {
    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ ${#1} -eq 0 ] && return 0

    [[ ! "${BD_DEBUG}" =~ ^[0-9]+$ ]] && export BD_DEBUG=0

    [ "${BD_DEBUG}" == '0' ] && return 0

    local bd_debug_msg=(${@})

    local bd_debug_level=${bd_debug_msg[${#bd_debug_msg[@]}-1]}
    if [[ "${bd_debug_level}" =~ ^[0-9]+$ ]]; then
        unset -v bd_debug_msg[${#bd_debug_msg[@]}-1] # remove level from bd_debug_msg; TODO: test with older bash versions
    else
        bd_debug_level=0
    fi

    [ ${BD_DEBUG} -eq 0 ] && [ ${bd_debug_level} -eq 0 ] && return 0

    if [ ${bd_debug_level} -le ${BD_DEBUG} ]; then
        bd_debug_msg="${bd_debug_msg[@]}"

        local bd_debug_bash_source=''
        local bd_debug_color

        if [ ${BD_DEBUG} -ge 2 ]; then
            bd_debug_bash_source="${BD_SOURCE}"
        else
            bd_debug_bash_source="${BD_SOURCE##*/}"
        fi

        [ ${bd_debug_level} -eq 1 ] && bd_debug_color="_gray1"
        [ ${bd_debug_level} -eq 2 ] && bd_debug_color="_white1"
        [ ${bd_debug_level} -eq 3 ] && bd_debug_color="_cyan1"
        [ ${bd_debug_level} -eq 4 ] && bd_debug_color="_magenta1"
        [ ${bd_debug_level} -eq 5 ] && bd_debug_color="_blue1"
        [ ${bd_debug_level} -eq 6 ] && bd_debug_color="_yellow1"
        [ ${bd_debug_level} -eq 7 ] && bd_debug_color="_green1"
        [ ${bd_debug_level} -eq 8 ] && bd_debug_color="_red1"

        [ ${#bd_debug_color} -eq 0 ] && let bd_debug_color=${bd_debug_level}+11

        type _bd_ansi &> /dev/null && printf "$(_bd_ansi reset)$(_bd_ansi fg${bd_debug_color})" 1>&2
        printf "[BD_DEBUG:%+2b:%b] [%b] %b" "${bd_debug_level}" "${BD_DEBUG}" "${bd_debug_bash_source}" "${bd_debug_msg}" 1>&2
        type _bd_ansi &> /dev/null && printf "$(_bd_ansi reset)" 1>&2
        printf "\n" 1>&2
    fi

    return 0
}
export -f _bd_debug

# color changing debug output for milliseconds
_bd_debug_ms() {

    [ ${#1} -eq 0 ] && return 0

    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ "${BD_DEBUG}" == '0' ] && return 0

    local bd_debug_ms_int=${1} bd_debug_ms_msg

    [[ ! "${bd_debug_ms_int}" =~ ^[0-9]+$ ]] && return

    [ ${bd_debug_ms_int} -le 100 ] && bd_debug_ms_msg="$(_bd_ansi fg_green1)[${bd_debug_ms_int}ms]$(_bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 100 ] && bd_debug_ms_msg="$(_bd_ansi fg_magenta1)[${bd_debug_ms_int}ms]$(_bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 499 ] && bd_debug_ms_msg="$(_bd_ansi fg_yellow1)[${bd_debug_ms_int}ms]$(_bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 999 ] && bd_debug_ms_msg="$(_bd_ansi fg_red1)[${bd_debug_ms_int}ms]$(_bd_ansi reset)"

    printf "${bd_debug_ms_msg}" # use as subshell; does not output to stderr

    return 0
}
export -f _bd_debug_ms

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
    bd_help+="  dir [hash | ls]                     - display only BD_AUTOLOADER_DIRS array values, and optionally hash or list them\n"
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

# load all config files & directories
_bd_load_config() {
    local bd_load_config_dir_name

    # ${BD_BITS_DIR}
    if [ ${#BD_BITS_DIR} -gt 0 ]; then
        if [ "${1}" != 'preload' ] && [ -d "${BD_BITS_DIR}" ] && [ -r "${BD_BITS_DIR}" ]; then
            _bd_autoloader_dir "${BD_BITS_DIR}"
        fi
    fi

    # ${BD_DIR}
    if [ ${#BD_DIR} -gt 0 ] && [ ${#BD_SUB_DIR} -gt 0 ]; then
        [ -f "${BD_DIR}/${BD_CONFIG_FILE}" ] && [ -r "${BD_DIR}/${BD_CONFIG_FILE}" ] && _bd_load_config_file "${BD_DIR}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${BD_DIR}/${BD_SUB_DIR}" ] && [ -r "${BD_DIR}/${BD_SUB_DIR}" ]; then
            _bd_autoloader_dir "${BD_DIR}/${BD_SUB_DIR}"

            _bd_load_config_dir "${BD_DIR}"
        fi
    fi

    # /${BD_SUB_DIR}/.. (/etc)
    if [ ${#BD_SUB_DIR} -gt 0 ] && [ "/${BD_SUB_DIR}/.." != "//.." ]; then
        [ -f "/${BD_SUB_DIR}/../${BD_CONFIG_FILE/./}" ] && [ -r "/${BD_SUB_DIR}/../${BD_CONFIG_FILE/./}" ] && _bd_load_config_file "/${BD_SUB_DIR}/../${BD_CONFIG_FILE/./}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "/${BD_SUB_DIR}" ] && [ -r "/${BD_SUB_DIR}" ]; then
            _bd_autoloader_dir "/${BD_SUB_DIR}"

            # sub-directories
            for bd_load_config_dir_name in "/${BD_SUB_DIR}"/*; do
                [ -d "${bd_load_config_dir_name}" ] && [ -r "${bd_load_config_dir_name}" ] && _bd_autoloader_dir "${bd_load_config_dir_name}"
            done

            _bd_load_config_dir /
        fi
    fi

    # ${HOME}
    if [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ]; then
        [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && _bd_load_config_file "${HOME}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${HOME}/${BD_SUB_DIR}" ] && [ -r "${HOME}/${BD_SUB_DIR}" ]; then
            _bd_autoloader_dir "${HOME}/${BD_SUB_DIR}"

            # sub-directories
            for bd_load_config_dir_name in "${HOME}/${BD_SUB_DIR}"/*; do
                [ -d "${bd_load_config_dir_name}" ] && [ -r "${bd_load_config_dir_name}" ] && _bd_autoloader_dir "${bd_load_config_dir_name}"
            done

            _bd_load_config_dir "${HOME}"
        fi
    fi

    # ${BD_HOME}
    if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ] && [ "${BD_HOME}" != "${HOME}" ]; then
        [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && _bd_load_config_file "${BD_HOME}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${BD_HOME}/${BD_SUB_DIR}" ] && [ -r "${BD_HOME}/${BD_SUB_DIR}" ]; then
            _bd_autoloader_dir "${BD_HOME}/${BD_SUB_DIR}"

            # sub-directories
            for bd_load_config_dir_name in "${BD_HOME}/${BD_SUB_DIR}"/*; do
                [ -d "${bd_load_config_dir_name}" ] && [ -r "${bd_load_config_dir_name}" ] && _bd_autoloader_dir "${bd_load_config_dir_name}"
            done

            _bd_load_config_dir "${BD_HOME}"
        fi
    fi

    # ${PWD}
    if [ ${#PWD} -gt 0 ] && [ "${PWD}" != "/etc" ] && [ "${PWD}" != "${BD_HOME}" ] && [ "${PWD}" != "${HOME}" ]; then
        [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && _bd_load_config_file "${PWD}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${PWD}/${BD_SUB_DIR}" ] && [ -r "${PWD}/${BD_SUB_DIR}" ]; then
            _bd_autoloader_dir "${PWD}/${BD_SUB_DIR}"

            # sub-directories
            for bd_load_config_dir_name in "${PWD}/${BD_SUB_DIR}"/*; do
                [ -d "${bd_load_config_dir_name}" ] && [ -r "${bd_load_config_dir_name}" ] && _bd_autoloader_dir "${bd_load_config_dir_name}"
            done

            _bd_load_config_dir "${PWD}"
        fi
    fi

    unset -v bd_load_config_dir_name
}
export -f _bd_load_config

# process BD_AUTOLOADER_CONFIG_DIRS with _bd_autoloader_dir(); i.e. look for etc/bash.d in other/specific locations
_bd_load_config_dir() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_load_config_dir_name="${1}"

    _bd_debug "bd_load_config_dir_name = ${bd_load_config_dir_name}" 10

    if [ ${#BD_AUTOLOADER_CONFIG_DIRS} -gt 0 ]; then
        local bd_load_config_dirs
        for bd_load_config_dirs in "${BD_AUTOLOADER_CONFIG_DIRS[@]}"; do
            if [ "${bd_load_config_dirs:0:1}" == "/" ]; then
                # qualified path
                [ -d "${bd_load_config_dirs}" ] && [ -r "${bd_load_config_dirs}" ] && _bd_autoloader_dir "${bd_load_config_dirs}"
            else
                # relative path
                [ -d "${bd_load_config_dir_name}/${bd_load_config_dirs}" ] && [ -r "${bd_load_config_dir_name}/${bd_load_config_dirs}" ] && _bd_autoloader_dir "${bd_load_config_dir_name}/${bd_load_config_dirs}"
            fi
        done
    fi
    unset -v BD_AUTOLOADER_CONFIG_DIRS
}
export -f _bd_load_config_dir

# load BD_ variables from config file
_bd_load_config_file() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_config_file_name="${1}"
    local bd_config_file_preload="${2}"

    if [ -r "${bd_config_file_name}" ]; then
        _bd_debug "bd_config_file_name=${bd_config_file_name} ${bd_config_file_preload}"

        local bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
        while read -r bd_config_file_line; do
            # only BD_* variables are supported
            [[ "${bd_config_file_line}" != 'BD_'* ]] && continue

            # resetting these will break bd & are not supported in config files
            [[ "${bd_config_file_line}" == 'BD_DIR'* ]] && continue

            _bd_debug "bd_config_file_line=${bd_config_file_line}" 20

            bd_config_file_variable_name="${bd_config_file_line%%=*}"

            _bd_debug "bd_config_file_variable_name=${bd_config_file_variable_name}" 4

            bd_config_file_variable_value="${bd_config_file_line#*=}"
            bd_config_file_variable_value="${bd_config_file_variable_value/\~/~}" # replace ~
            bd_config_file_variable_value="${bd_config_file_variable_value%%'#'*}" # remove trailing comments
            bd_config_file_variable_value="${bd_config_file_variable_value%"${bd_config_file_variable_value##*[![:space:]]}"}" # remove trailing spaces
            bd_config_file_variable_value="${bd_config_file_variable_value%\"*}" # remove opening "
            bd_config_file_variable_value="${bd_config_file_variable_value#\"*}" # remove closing "
            bd_config_file_variable_value="${bd_config_file_variable_value%\'*}" # remove opening '
            bd_config_file_variable_value="${bd_config_file_variable_value#\'*}" # remove closing '

            _bd_debug "bd_config_file_variable_value=${bd_config_file_variable_value}" 11

            # 0.44.0, note BD_BAG_DIR is deprecated & will be removed in 1.0
            if [ "${bd_config_file_variable_name}" == 'BD_AUTOLOADER_DIR' ] || [ "${bd_config_file_variable_name}" == 'BD_BAG_DIR' ]; then
                [ "${bd_config_file_preload}" == "preload" ] && continue
                _bd_debug "export BD_AUTOLOADER_CONFIG_DIRS+=(\"${bd_config_file_variable_value}\")" 15
                export BD_AUTOLOADER_CONFIG_DIRS+=("${bd_config_file_variable_value}")
            else
                [ "${bd_config_file_preload}" != "preload" ] && continue
                _bd_debug "export ${bd_config_file_variable_name}=\"${bd_config_file_variable_value}\"" 15
                export "${bd_config_file_variable_name}"="${bd_config_file_variable_value}" # does not work with set -a?
            fi
        done < "${bd_config_file_name}"
        unset -v bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
    else
        return 1
    fi
}
export -f _bd_load_config_file

# main entrypoint
_bd_main() {
    _bd_debug "${FUNCNAME}(${@})" 55

    _bd_debug "${BASH_SOURCE} main begin" 25

    if [ ${#BD_DEBUG} -gt 0 ]; then
        # capture start time
        local bd_begin_time=$(_bd_uptime)

        _bd_debug "${BASH_SOURCE} BD_DEBUG=${BD_DEBUG}"
    fi

    # bootstrap

    _bd_bootstrap || return 1

    # handle options

    unset -v BD_RC

    local bd_main_option=1

    case "${1}" in
        bits|b|--bits|-b)
            _bd_bits ${@}
            ;;
        dir*|d|--dir*|-d)
            _bd_sundry ${@}
            ;;
        env*|e|--env|-e)
            _bd_sundry ${@}
            ;;
        functions|--functions)
            # functions argument (don't do anything)
            return 0
            ;;
        help|h|--help|-h)
            _bd_help
            ;;
        license|--license)
            _bd_license
            ;;
        upgrade|--upgrade)
            _bd_upgrade "${BD_DIR}"
            ;;
        ver*|v|--ver*|-v)
            _bd_sundry version
            ;;
        *)
            bd_main_option=0

            _bd_debug "${BD_SOURCE} ${1} pass; invoke autoloader" 10

            _bd_autoloader ${@}
            ;;
    esac

    BD_RC=$?

    if [ ${BD_RC} -ne 0 ]; then
        _bd_debug "${BD_SOURCE} ${1} fail; rc=${BD_RC}, bd_main_option=${bd_main_option}" 10

        _bd_namespace_reset private

        return ${BD_RC}
    fi

    _bd_debug "${BD_SOURCE} ${1} pass; rc=${BD_RC}, bd_main_opton=${bd_main_option}" 10

    if [ ${BD_RC} -ne 0 ] && [ ${bd_main_option} -eq 1 ]; then
        _bd_namespace_reset private

        return ${BD_RC}
    fi

    if [ ${#BD_DEBUG} -gt 0 ]; then
        # calculate run times
        local bd_end_time bd_total_time bd_total_time_ms
        bd_end_time=$(_bd_uptime 2> /dev/null)
        [[ "${bd_begin_time}" =~ ^[0-9]+$ ]] && [[ "${bd_end_time}" =~ ^[0-9]+$ ]] && bd_total_time=$((${bd_end_time}-${bd_begin_time}))
        bd_total_time_ms="$(_bd_debug_ms ${bd_total_time} 2> /dev/null)"
    fi

    # reset namespace

    _bd_namespace_reset private

    _bd_debug "${BD_SOURCE} main end ${bd_total_time_ms}"
}
export -f _bd_main

# initialize bd (namespace)
_bd_namespace_init() {
    _bd_debug "${FUNCNAME}(${@})" 55

    # reset namespace; ensure (most of the) included bd- aliases, bd_ functions, & BD_ variables
    _bd_namespace_reset init

    if [ ${#BD_DIR} -gt 0 ] && [ -d "${BD_DIR}" ] && type -P git &> /dev/null; then
        BD_GIT_URL="$(cd "${BD_DIR}" && git remote get-url $(git remote 2> /dev/null) 2> /dev/null)"
    fi
    [ ${#BD_GIT_URL} -eq 0 ] && BD_GIT_URL="https://github.com/bash-d/bd"

    export BD_GIT_URL

    _bd_debug "BD_GIT_URL = ${BD_GIT_URL}" 2

    _bd_load_config preload

    _bd_os

    # ensure BD_AUTOLOADER_DIRS, BD_AUTOLOADER_CONFIG_DIRS, BD_BASH_INIT_FILE, BD_HOME, BD_USER, & USER

    unset -v BD_AUTOLOADER_CONFIG_DIRS

    # TODO: learn requires more testing
    _bd_true ${BD_LEARN} || export BD_AUTOLOADER_DIRS=()

    [ "${EUID}" == '0' ] && USER=root

    [ "${USER}" != 'root' ] && unset BD_USER # honor sudo --preserve-env=BD_USER

    # preferred order of sources for BD_USER
    [ ${#BD_USER} -eq 0 ] && [ "${USER}" == 'root' ] && type -P logname &> /dev/null && BD_USER=$(logname 2> /dev/null) # hack; only use logname for root?
    [ ${#BD_USER} -eq 0 ] && [ ${#USER} -gt 0 ] && BD_USER=${USER} # default to ${USER}
    [ ${#BD_USER} -eq 0 ] && [ ${#USERNAME} -gt 0 ] && BD_USER=${USERNAME}
    [ ${#BD_USER} -eq 0 ] && type -P who &> /dev/null && BD_USER=$(who -m 2> /dev/null)
    [ ${#BD_USER} -eq 0 ] && [ ${#SUDO_USER} -gt 0 ] && BD_USER=${SUDO_USER}
    [ ${#BD_USER} -eq 0 ] && [ ${#LOGNAME} -gt 0 ] && BD_USER=${LOGNAME}

    export BD_USER

    [ ${#USER} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && USER=${BD_USER}

    [ "${USER}" != 'root' ] && unset BD_HOME # honor sudo --preserve-env=BD_HOME

    [ ${#BD_USER} -eq 0 ] && BD_HOME="/tmp"

    # preferred order of sources for BD_HOME
    [ ${#BD_HOME} -eq 0 ] && [ ${#HOME} -gt 0 ] && BD_HOME=${HOME} # default to ${HOME}
    [ ${#BD_HOME} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && type -P getent &> /dev/null && BD_HOME=$(getent passwd ${BD_USER} 2> /dev/null) && BD_HOME=${BD_HOME%%:*}
    [ ${#BD_HOME} -eq 0 ] && BD_HOME="~"

    export BD_HOME

    if shopt -q login_shell; then
        # login shell
        [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"
        [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r ~/.bash_profile ] && BD_BASH_INIT_FILE=~/.bash_profile
    fi

    # not a login shell, or it is a login shell and there's no ~/.bash_profile
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bashrc" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bashrc"
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"

    export BD_BASH_INIT_FILE

    _bd_load_config

    _bd_debug "BD_AUTOLOADER_DIRS = ${BD_AUTOLOADER_DIRS[@]} # (after _bd_load_config)" 1

}
export -f _bd_namespace_init

# avoid name collisions (from excessive sourcing, etc)
_bd_namespace_reset() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_alias bd_declare bd_function bd_variable
    local bd_alias_name bd_alias_names=()
    local bd_function_name bd_function_names=()
    local bd_variable_name bd_variable_names=()
    local bd_unset_oifs

    bd_variable_names+=("BD_RC")

    bd_unset_oifs="${IFS}"
    IFS=$'\n'
    for bd_declare in $(declare -g 2> /dev/null); do
        # function names
        if [[ "${bd_declare}" == '_bd_'*' () ' ]]; then
            bd_function_name="${bd_declare%% *}"
        fi

        # variable names
        if [[ "${bd_declare}" == 'BD_'*'='* ]]; then
            bd_variable_name="${bd_declare%%=*}"

            [[ "${bd_variable_name}" == 'BD_'*'_SOURCED'* ]] && bd_variable_names+=("${bd_variable_name}")
        fi
    done
    IFS="${bd_unset_oifs}"

    # additional, conditional

    if [ "${1}" == 'init' ]; then
        # alias names

        bd_alias_names+=(bd)

        # function names

        # variable names

        bd_unset_oifs="${IFS}"
        IFS=$'\n'
        for bd_declare in $(declare -g 2> /dev/null); do
            # this loop resets virtually all BD_* variables that are not excluded (preserved)
            if [[ "${bd_declare}" == 'BD_'*'='* ]]; then
                bd_variable_name="${bd_declare%%=*}"

                # exclude privates
                _bd_private "${bd_variable_name}" && continue

                # exclude these, too
                [ "${bd_variable_name}" == 'BD_CLIPBOARD' ] && continue
                [ "${bd_variable_name}" == 'BD_DEBUG' ] && continue
                [ "${bd_variable_name}" == 'BD_DIR' ] && continue
                [ "${bd_variable_name}" == 'BD_HOME' ] && continue
                [ "${bd_variable_name}" == 'BD_LEARN' ] && continue
                [ "${bd_variable_name}" == 'BD_SOURCE' ] && continue
                [ "${bd_variable_name}" == 'BD_BITS_DIR' ] && continue
                [ "${bd_variable_name}" == 'BD_USER' ] && continue
                [ "${bd_variable_name}" == 'BD_VERSION' ] && continue

                [[ "${bd_variable_name}" == 'BD_'*'_EXPORT' ]] && continue

                if [ "${bd_variable_name}" == 'BD_AUTOLOADER_DIRS' ]; then
                    if ! _bd_true ${BD_LEARN}; then
                        bd_variable_names+=("${bd_variable_name}")
                    fi
                else
                    bd_variable_names+=("${bd_variable_name}")
                fi
            fi
        done
        IFS="${bd_unset_oifs}"
    fi

    # so-called 'private' names that will be reset
    if [ "${1}" == 'private' ]; then
        # private function names

        bd_function_names+=(_bd_autoloader)
        bd_function_names+=(_bd_autoloader_dir)
        bd_function_names+=(_bd_autoloader_execute)
        bd_function_names+=(_bd_autoloader_execute_array)
        bd_function_names+=(_bd_bootstrap)
        bd_function_names+=(_bd_caller)
        bd_function_names+=(_bd_load_config)
        bd_function_names+=(_bd_load_config_dir)
        bd_function_names+=(_bd_load_config_file)
        bd_function_names+=(_bd_namespace_init)
        bd_function_names+=(_bd_namespace_reset)
        bd_function_names+=(_bd_main)
        bd_function_names+=(_bd_private)
        bd_function_names+=(_bd_realpath)
        bd_function_names+=(_bd_uptime)

        # private variable names

        bd_variable_names+=($(_bd_private echo))
    fi

    # unalias aliase names
    for bd_alias_name in ${bd_alias_names[@]}; do
        alias "${bd_alias_name}" &> /dev/null && unalias "${bd_alias_name}" && _bd_debug "unalias ${bd_alias_name}" 5
    done

    # unset function names
    for bd_function_name in ${bd_function_names[@]}; do
        unset -f "${bd_function_name}" && _bd_debug "unset -f ${bd_function_name}" 15
    done

    # unset variabe names
    for bd_variable_name in ${bd_variable_names[@]}; do
        unset -v ${bd_variable_name} && _bd_debug "unset -v ${bd_variable_name}" 15
    done

    if [ "${1}" != 'init' ]; then
        # functions used locally (& self)
        unset -f _bd_true _bd_namespace_init _bd_namespace_reset
    fi
}
export -f _bd_namespace_reset

# determine operating system; export BD_OS value (needed for _bd_uptime)
_bd_os() {
    export BD_OS='unknown'

    if type -P uname &> /dev/null; then
        BD_OS_KERNEL_NAME="$(command -p uname -s 2> /dev/null)"

        if [ ${BASH_VERSINFO[0]} -ge 4 ]; then
            BD_OS_KERNEL_NAME=${BD_OS_KERNEL_NAME,,}
        else
            BD_OS_KERNEL_NAME="$(tr [A-Z] [a-z] <<< "${BD_OS_KERNEL_NAME}")" # posix (bash 3; [i.e. darwin])
        fi

        case "${BD_OS_KERNEL_NAME}" in
            bsd*)                           BD_OS='bsd';;
            darwin*)                        BD_OS='darwin';;
            linux*)                         BD_OS='linux';;
            solaris*)                       BD_OS='solaris';;
            cygwin*|mingw*|win*)            BD_OS='windows';;
            linux*microsoft*)               BD_OS='wsl';;
            *)                              BD_OS="unknown:${BD_OS_KERNEL_NAME}"
        esac

        unset -v BD_OS_KERNEL_NAME
    fi

    _bd_debug "BD_OS = ${BD_OS}" 1
}
export -f _bd_os

# return true for bd private variables (et al)
_bd_private() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_private_variable_name bd_private_variable_names

    bd_private_variable_names=()

    bd_private_variable_names+=('BD_SUB_DIR')
    bd_private_variable_names+=('BD_CONFIG_FILE')
    bd_private_variable_names+=('BD_DECLARE')
    bd_private_variable_names+=('BD_OIFS')

    if [ "${1}" == 'echo' ]; then
        echo "${bd_private_variable_names[@]}"
        return
    fi

    for bd_private_variable_name in ${bd_private_variable_names[@]}; do
        [ "${1}" == "${bd_private_variable_name}" ] && return 0
    done


    return 1
}
export -f _bd_private

# semi-portable readlink/realpath
_bd_realpath() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_realpath_arg="${1}"

    [ ${#bd_realpath_arg} -eq 0 ] && return 1

    [ -z "${BD_REALPATH}" ] && type -P realpath &> /dev/null && export BD_REALPATH="realpath" # preferred per GNU
    [ -z "${BD_REALPATH}" ] && type -P readlink &> /dev/null && export BD_REALPATH="readlink -f "

    if [ -z "${BD_REALPATH}" ]; then
        # NOTE: this logic covers many use cases, but not all.
        local bd_realpath_basename bd_realpath_dirname bd_realpath_name

        if [ -r "${bd_realpath_arg}" ]; then
            if [ -d "${bd_realpath_arg}" ]; then
                bd_realpath_name="$(cd "${bd_realpath_arg}" &> /dev/null; pwd -P)"
            else
                bd_realpath_dirname="${bd_realpath_arg%/*}"
                if [ -d "${bd_realpath_dirname}" ]; then
                    >&2 echo "bd_realpath_dirname=${bd_realpath_dirname}"

                    bd_realpath_basename="${bd_realpath_arg##*/}"
                    bd_realpath_name="$(cd "${bd_realpath_dirname}" &> /dev/null; pwd -P)"
                    [ ${#bd_realpath_basename} -gt 0 ] && bd_realpath_name+="/${bd_realpath_basename}"
                fi
            fi
        fi

        printf "${bd_realpath_name}"
    else
        ${BD_REALPATH} "${bd_realpath_arg}"
    fi
}
export -f _bd_realpath

# return 0 if 1, true, or yes
_bd_true() {
    _bd_debug "${FUNCNAME}(${@})" 55

    if [ "${1}" == '1' ] || [ "${1}" == 'true' ] || [ "${1}" == 'yes' ]; then
        return 0
    else
        return 1
    fi
}
export -f _bd_true

# output milliseconds since uptime (used for debugging)
_bd_uptime() {
    _bd_debug "${FUNCNAME}(${@})" 55

    local bd_uptime_ms bd_uptime_t1
    if [ ${BASH_VERSINFO[0]} -ge 5 ]; then
        bd_uptime_t1=${EPOCHREALTIME//.}
        bd_uptime_ms=$((${bd_uptime_t1}/1000))
    else
        local bd_uptime_t0
        if [ "${BD_OS}" == 'linux' ] || [ "${BD_OS}" == 'windows' ] || [ "${BD_OS}" == 'wsl' ]; then
            local bd_uptime_idle
            # linux & windows; use /proc/uptime
            read bd_uptime_t0 bd_uptime_idle < /proc/uptime
            bd_uptime_t1="${bd_uptime_t0//.}"
            bd_uptime_ms=$((${bd_uptime_t1}*10))
        fi

        if [ "${BD_OS}" == 'darwin' ]; then
            # bsd & darwin; use sysctl
            bd_uptime_t0="$(command -p sysctl -n kern.boottime 2> /dev/null)"
            bd_uptime_t1="${bd_uptime_t0%,*}"
            bd_uptime_t1="${bd_uptime_t1##* }"
            bd_uptime_ms=$((($(command -p date +%s)-${bd_uptime_t1})*1000))
        fi
    fi

    printf "${bd_uptime_ms}"
}
export -f _bd_uptime

#
# main
#

_bd_main ${@}
