# bd.sh: bash directory (bash.d) autoloader

# https://github.com/bash-d/bd/blob/main/README.md

# Copyright (C) 2018-2023 Joseph Tingiris <joseph.tingiris@gmail.com>
# https://github.com/bash-d/bd/blob/main/LICENSE.md

#
# init
#

# prevent non-bash bourne compatible shells
[ "${BASH_SOURCE}" == '' ] && return &> /dev/null

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (try 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

# prevent recursive execution
export BD_CALLERS_MAX=3
export BD_CALLERS=$((${#BASH_ARGC[@]}-1))

[ ${BD_CALLERS} -gt ${BD_CALLERS_MAX} ] && unset -v BD_CALLERS BD_CALLERS_MAX && return

if [ ${BD_CALLERS} -gt ${BD_CALLERS_MAX} ]; then
    # see bash manual
    bd_debug "BASH_ARGC = ${BASH_ARGC[@]} (${#BASH_ARGC[@]})" 2
    bd_debug "BD_CALLERS = ${BD_CALLERS} (>${BD_CALLERS_MAX})" 2
    return
fi
unset -v BD_CALLERS BD_CALLERS_MAX

#
# config
#

export BD_VERSION=0.44.1

export BD_AUTOLOAD_DEFAULT_DIR='etc/bash.d'

export BD_CONFIG_FILE='.bd.conf'

#
# functions
#

# stub bd_ansi() until bd-ansi.sh is properly loaded (for embedded bd_debug)
if ! type -t bd_ansi &> /dev/null; then
    if [ -r "${BD_DIR}/${BD_AUTOLOAD_DEFAULT_DIR}/bd-ansi.sh" ]; then
        source "${BD_DIR}/${BD_AUTOLOAD_DEFAULT_DIR}/bd-ansi.sh"
    else
        bd_ansi() {
            return
        }
    fi
fi

# set bd aliases
bd_aliases() {
    bd_debug "${FUNCNAME}(${@})" 55

    if ! type -P bd-ansi &> /dev/null; then
        if [ -r "${BD_DIR}/bin/bd-ansi" ]; then
            [ ! -x "${BD_DIR}/bin/bd-ansi" ] && chmod u+x "${BD_DIR}/bin/bd-ansi"
            if "${BD_DIR}/bin/bd-ansi" reset &> /dev/null; then
                alias bd-ansi="${BD_DIR}/bin/bd-ansi"
            else
                alias bd-ansi=false
            fi
        else
            alias bd-ansi=false
        fi
    fi

    if ! type -P bd-debug &> /dev/null; then
        if [ -r "${BD_DIR}/bin/bd-debug" ]; then
            [ ! -x "${BD_DIR}/bin/bd-debug" ] && chmod u+x "${BD_DIR}/bin/bd-debug"
            alias bd-debug="${BD_DIR}/bin/bd-debug"
        else
            alias bd-debug=false
        fi
    fi
}

# call bd_autoload_dir on an array (of directories)
bd_autoload() {
    bd_debug "${FUNCNAME}(${@})" 55

    [ ${#1} -eq 0 ] && return 1

    local bd_autoload_dir_name bd_autoload_finish bd_autoload_start bd_autoload_total bd_autoload_total_ms

    for bd_autoload_dir_name  in "${@}"; do
        [ ${#BD_DEBUG} -gt 0 ] && bd_autoload_start=$(bd_uptime)

        bd_autoload_dir "${bd_autoload_dir_name}"

        if [ ${#BD_DEBUG} -gt 0 ]; then
            bd_autoload_finish=$(bd_uptime)
            bd_autoload_total=$((${bd_autoload_finish}-${bd_autoload_start}))
            bd_autoload_total_ms="$(bd_debug_ms ${bd_autoload_total})"
            bd_debug "bd_autoload_dir ${bd_autoload_dir_name} ${bd_autoload_total_ms}"
        fi
    done
    unset -v bd_autoload_dir_name bd_autoload_finish bd_autoload_start bd_autoload_total bd_autoload_total_ms
}

# source everything in a given directory (that ends in .sh)
bd_autoload_dir() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_autoloader_dir_name="${1}"

    if [ -d "${bd_autoloader_dir_name}" ] && [ -r "${bd_autoloader_dir_name}" ]; then
        local bd_autoloader_file bd_autoloader_file_realpath

        local bd_autoloader_files=()

        # LC_COLLATE consistency hack (due to bsd/darwin differences)
        # https://blog.zhimingwang.org/macos-lc_collate-hunt
        # https://collation-charts.org/fbsd54/

        local bd_autoloader_lc_collate="${LC_COLLATE}"

        LC_COLLATE=POSIX # required for consistent collation across operating systems
        for bd_autoloader_file in "${bd_autoloader_dir_name}"/*\.{bash,sh}; do
            bd_autoloader_files+=("${bd_autoloader_file}")
        done
        unset -v bd_autoloader_file

        [ ${#bd_autoloader_lc_collate} -gt 0 ] && LC_COLLATE="${bd_autoloader_lc_collate}" || unset -v LC_COLLATE

        for bd_autoloader_file in "${bd_autoloader_files[@]}"; do

            # don't source itself ...
            [ "${bd_autoloader_file}" == "${BD_SOURCE}" ] && bd_debug "${FUNCNAME} ${bd_autoloader_file} matches relative path" 13 && continue # relative location
            [ "${bd_autoloader_file}" == "${BD_SOURCE##*/}" ] && bd_debug "${FUNCNAME}) ${bd_autoloader_file} matches basename" 13 && continue # basename

            if [ -r "${bd_autoloader_file}" ]; then
                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_autoloader_source_start
                    bd_autoloader_source_start=$(bd_uptime)
                fi

                bd_debug "source  ${bd_autoloader_file} ..." 4

                source "${bd_autoloader_file}" '' # pass an empty arg to ${1}

                if [ ${#BD_DEBUG} -gt 0 ]; then
                    local bd_autoloader_source_finish bd_autoloader_source_total bd_autoloader_source_total_ms
                    bd_autoloader_source_finish=$(bd_uptime)
                    bd_autoloader_source_total=$((${bd_autoloader_source_finish}-${bd_autoloader_source_start}))
                    bd_autoloader_source_total_ms=$(bd_debug_ms ${bd_autoloader_source_total})
                    bd_debug "source ${bd_autoloader_file} ${bd_autoloader_source_total_ms}" 3
                fi
            fi
        done
        unset -v bd_autoloader_file bd_autoloader_files
    fi
}

# return true for bd exclusive variables
bd_exclusive_variable() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_exclusive_variable_name bd_exclusive_variable_names

    bd_exclusive_variable_names=()
    bd_exclusive_variable_names+=('BD_ANSI_SOURCED')
    bd_exclusive_variable_names+=('BD_AUTOLOAD_DEFAULT_DIR')
    bd_exclusive_variable_names+=('BD_CONFIG_FILE')
    bd_exclusive_variable_names+=('BD_DECLARE')
    bd_exclusive_variable_names+=('BD_DEBUG_EXCLUSIVE')
    bd_exclusive_variable_names+=('BD_OIFS')
    bd_exclusive_variable_names+=('BD_VARIABLE_NAME')

    for bd_exclusive_variable_name in ${bd_exclusive_variable_names[@]}; do
        [ "${1}" == "${bd_exclusive_variable_name}" ] && return 0
    done

    unset -v bd_exclusive_variable_name bd_exclusive_variable_names

    return 1
}

# formatted debug output
bd_debug() {
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

        type bd_ansi &> /dev/null && printf "$(bd_ansi reset)$(bd_ansi fg${bd_debug_color})" 1>&2
        printf "[BD_DEBUG:%+2b:%b] [%b] %b" "${bd_debug_level}" "${BD_DEBUG}" "${bd_debug_bash_source}" "${bd_debug_msg}" 1>&2
        type bd_ansi &> /dev/null && printf "$(bd_ansi reset)" 1>&2
        printf "\n" 1>&2
    fi

    return 0
}

# colored debug output for milliseconds
bd_debug_ms() {

    [ ${#1} -eq 0 ] && return 0

    [ ${#BD_DEBUG} -eq 0 ] && return 0

    [ "${BD_DEBUG}" == '0' ] && return 0

    local bd_debug_ms_int=${1} bd_debug_ms_msg

    [[ ! "${bd_debug_ms_int}" =~ ^[0-9]+$ ]] && return

    [ ${bd_debug_ms_int} -le 100 ] && bd_debug_ms_msg="$(bd_ansi fg_green1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 100 ] && bd_debug_ms_msg="$(bd_ansi fg_magenta1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 499 ] && bd_debug_ms_msg="$(bd_ansi fg_yellow1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"
    [ ${bd_debug_ms_int} -gt 999 ] && bd_debug_ms_msg="$(bd_ansi fg_red1)[${bd_debug_ms_int}ms]$(bd_ansi reset)"

    printf "${bd_debug_ms_msg}" # use as subshell; does not output to stderr

    return 0
}

# (only) add unique, existing directories to the BD_AUTOLOAD_DIRS array (& preserve the natural order)
bd_load() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_load_dir_name="${1//\/\//\/}"

    bd_load_dir_name="${bd_load_dir_name//\/\//\/}"
    bd_load_dir_name="${bd_load_dir_name//\/\//\/}"

    bd_debug "1 bd_load_dir_name = ${bd_load_dir_name}" 6

    [ ${#bd_load_dir_name} -eq 0 ] && return 1

    [ ! -d "${bd_load_dir_name}" ] && return 1

    bd_load_dir_name="$(bd_realpath "${bd_load_dir_name}")"

    bd_debug "2 bd_load_dir_name = ${bd_load_dir_name}" 6

    [ ${#BD_AUTOLOAD_DIRS} -eq 0 ] && export BD_AUTOLOAD_DIRS=()

    local bd_load_dir_exists=0 # false

    local bd_load_autoload_dir_name
    for bd_load_autoload_dir_name in ${BD_AUTOLOAD_DIRS[@]}; do
        [ ${bd_load_dir_exists} -eq 1 ] && break
        [ "${bd_load_autoload_dir_name}" == "${bd_load_dir_name}" ] && bd_load_dir_exists=1
    done
    unset -v bd_load_autoload_dir_name

    [ ${bd_load_dir_exists} -eq 0 ] && BD_AUTOLOAD_DIRS+=("${bd_load_dir_name}") && bd_debug "bd_load_dir_name = ${bd_load_dir_name}" 2

    unset -v bd_load_dir_exists
}

# process BD_AUTOLOAD_CONFIG_DIRS with bd_load(); i.e. look for etc/bash.d in other/specific locations
bd_load_config_dir() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_load_config_dir_name="${1}"

    bd_debug "bd_load_config_dir_name = ${bd_load_config_dir_name}" 1

    if [ ${#BD_AUTOLOAD_CONFIG_DIRS} -gt 0 ]; then
        local bd_load_config_dirs
        for bd_load_config_dirs in "${BD_AUTOLOAD_CONFIG_DIRS[@]}"; do
            if [ "${bd_load_config_dirs:0:1}" == "/" ]; then
                # qualified path
                [ -d "${bd_load_config_dirs}" ] && [ -r "${bd_load_config_dirs}" ] && bd_load "${bd_load_config_dirs}"
            else
                # relative path
                [ -d "${bd_load_config_dir_name}/${bd_load_config_dirs}" ] && [ -r "${bd_load_config_dir_name}/${bd_load_config_dirs}" ] && bd_load "${bd_load_config_dir_name}/${bd_load_config_dirs}"
            fi
        done
        unset -v bd_load_config_dirs
    fi
    unset -v BD_AUTOLOAD_CONFIG_DIRS
}

# load BD_ environment variables from config file
bd_load_config_file() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_config_file_name="${1}"
    local bd_config_file_preload="${2}"

    if [ -r "${bd_config_file_name}" ]; then
        bd_debug "bd_config_file_name=${bd_config_file_name} ${bd_config_file_preload}"

        local bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
        while read -r bd_config_file_line; do
            # only BD_* variables are supported
            [[ "${bd_config_file_line}" != 'BD_'* ]] && continue

            # resetting these will break bd & are not supported in config files
            [[ "${bd_config_file_line}" == 'BD_DIR'* ]] && continue

            bd_debug "bd_config_file_line=${bd_config_file_line}" 20

            bd_config_file_variable_name="${bd_config_file_line%%=*}"

            bd_debug "bd_config_file_variable_name=${bd_config_file_variable_name}" 4

            bd_config_file_variable_value="${bd_config_file_line#*=}"
            bd_config_file_variable_value="${bd_config_file_variable_value/\~/~}" # replace ~
            bd_config_file_variable_value="${bd_config_file_variable_value%%'#'*}" # remove trailing comments
            bd_config_file_variable_value="${bd_config_file_variable_value%"${bd_config_file_variable_value##*[![:space:]]}"}" # remove trailing spaces
            bd_config_file_variable_value="${bd_config_file_variable_value%\"*}" # remove opening "
            bd_config_file_variable_value="${bd_config_file_variable_value#\"*}" # remove closing "
            bd_config_file_variable_value="${bd_config_file_variable_value%\'*}" # remove opening '
            bd_config_file_variable_value="${bd_config_file_variable_value#\'*}" # remove closing '

            bd_debug "bd_config_file_variable_value=${bd_config_file_variable_value}" 11

            # 0.44.0, note BD_BAG_DIR is deprecated & will be removed in 1.0
            if [ "${bd_config_file_variable_name}" == 'BD_AUTOLOAD_DIR' ] || [ "${bd_config_file_variable_name}" == 'BD_BAG_DIR' ]; then
                [ "${bd_config_file_preload}" == "preload" ] && continue
                bd_debug "export BD_AUTOLOAD_CONFIG_DIRS+=(\"${bd_config_file_variable_value}\")" 15
                export BD_AUTOLOAD_CONFIG_DIRS+=("${bd_config_file_variable_value}")
            else
                [ "${bd_config_file_preload}" != "preload" ] && continue
                bd_debug "export ${bd_config_file_variable_name}=\"${bd_config_file_variable_value}\"" 15
                export "${bd_config_file_variable_name}"="${bd_config_file_variable_value}" # does not work with set -a?
            fi
        done < "${bd_config_file_name}"
        unset -v bd_config_file_line bd_config_file_variable_name bd_config_file_variable_value
    else
        return 1
    fi
}

# load config files & load all directories
bd_load_config_files() {

    local bd_config_files_dir_name

    # ${BD_DIR}
    if [ ${#BD_AUTOLOAD_DEFAULT_DIR} -gt 0 ] && [ ${#BD_DIR} -gt 0 ]; then
        [ -f "${BD_DIR}/${BD_CONFIG_FILE}" ] && [ -r "${BD_DIR}/${BD_CONFIG_FILE}" ] && bd_load_config_file "${BD_DIR}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${BD_DIR}/${BD_AUTOLOAD_DEFAULT_DIR}" ] && [ -r "${BD_DIR}/${BD_AUTOLOAD_DEFAULT_DIR}" ]; then
            bd_load "${BD_DIR}/${BD_AUTOLOAD_DEFAULT_DIR}"

            bd_load_config_dir "${BD_DIR}"
        fi
    fi

    # /${BD_AUTOLOAD_DEFAULT_DIR}/.. (/etc)
    if [ ${#BD_AUTOLOAD_DEFAULT_DIR} -gt 0 ] && [ "/${BD_AUTOLOAD_DEFAULT_DIR}/.." != "//.." ]; then
        [ -f "/${BD_AUTOLOAD_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" ] && [ -r "/${BD_AUTOLOAD_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" ] && bd_load_config_file "/${BD_AUTOLOAD_DEFAULT_DIR}/../${BD_CONFIG_FILE/./}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "/${BD_AUTOLOAD_DEFAULT_DIR}" ] && [ -r "/${BD_AUTOLOAD_DEFAULT_DIR}" ]; then
            bd_load "/${BD_AUTOLOAD_DEFAULT_DIR}"

            # sub-directories
            for bd_config_files_dir_name in "/${BD_AUTOLOAD_DEFAULT_DIR}"/*; do
                [ -d "${bd_config_files_dir_name}" ] && [ -r "${bd_config_files_dir_name}" ] && bd_load "${bd_config_files_dir_name}"
            done

            bd_load_config_dir /
        fi
    fi

    # ${HOME}
    if [ ${#HOME} -gt 0 ] && [ "${HOME}" != "/" ]; then
        [ -f "${HOME}/${BD_CONFIG_FILE}" ] && [ -r "${HOME}/${BD_CONFIG_FILE}" ] && bd_load_config_file "${HOME}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${HOME}/${BD_AUTOLOAD_DEFAULT_DIR}" ] && [ -r "${HOME}/${BD_AUTOLOAD_DEFAULT_DIR}" ]; then
            bd_load "${HOME}/${BD_AUTOLOAD_DEFAULT_DIR}"

            # sub-directories
            for bd_config_files_dir_name in "${HOME}/${BD_AUTOLOAD_DEFAULT_DIR}"/*; do
                [ -d "${bd_config_files_dir_name}" ] && [ -r "${bd_config_files_dir_name}" ] && bd_load "${bd_config_files_dir_name}"
            done

            bd_load_config_dir "${HOME}"
        fi
    fi

    # ${BD_HOME}
    if [ ${#BD_HOME} -gt 0 ] && [ "${BD_HOME}" != "/" ] && [ "${BD_HOME}" != "${HOME}" ]; then
        [ -f "${BD_HOME}/${BD_CONFIG_FILE}" ] && [ -r "${BD_HOME}/${BD_CONFIG_FILE}" ] && bd_load_config_file "${BD_HOME}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${BD_HOME}/${BD_AUTOLOAD_DEFAULT_DIR}" ] && [ -r "${BD_HOME}/${BD_AUTOLOAD_DEFAULT_DIR}" ]; then
            bd_load "${BD_HOME}/${BD_AUTOLOAD_DEFAULT_DIR}"

            # sub-directories
            for bd_config_files_dir_name in "${BD_HOME}/${BD_AUTOLOAD_DEFAULT_DIR}"/*; do
                [ -d "${bd_config_files_dir_name}" ] && [ -r "${bd_config_files_dir_name}" ] && bd_load "${bd_config_files_dir_name}"
            done

            bd_load_config_dir "${BD_HOME}"
        fi
    fi

    # ${PWD}
    if [ ${#PWD} -gt 0 ] && [ "${PWD}" != "/etc" ] && [ "${PWD}" != "${BD_HOME}" ] && [ "${PWD}" != "${HOME}" ]; then
        [ -f "${PWD}/${BD_CONFIG_FILE}" ] && [ -r "${PWD}/${BD_CONFIG_FILE}" ] && bd_load_config_file "${PWD}/${BD_CONFIG_FILE}" ${1}

        if [ "${1}" != 'preload' ] && [ -d "${PWD}/${BD_AUTOLOAD_DEFAULT_DIR}" ] && [ -r "${PWD}/${BD_AUTOLOAD_DEFAULT_DIR}" ]; then
            bd_load "${PWD}/${BD_AUTOLOAD_DEFAULT_DIR}"

            # sub-directories
            for bd_config_files_dir_name in "${PWD}/${BD_AUTOLOAD_DEFAULT_DIR}"/*; do
                [ -d "${bd_config_files_dir_name}" ] && [ -r "${bd_config_files_dir_name}" ] && bd_load "${bd_config_files_dir_name}"
            done

            bd_load_config_dir "${PWD}"
        fi
    fi

    unset -v bd_config_files_dir_name
}

# semi-portable readlink/realpath
bd_realpath() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_realpath_arg="${1}"

    [ ${#bd_realpath_arg} -eq 0 ] && return 1

    [ -z "${BD_REALPATH}" ] && type -P realpath &> /dev/null && export BD_REALPATH="realpath" # preferred per GNU
    [ -z "${BD_REALPATH}" ] && type -P realpath &> /dev/null && export BD_REALPATH="readlink -f "

    if [ -z "${BD_REALPATH}" ]; then
        # NOTE: this logic covers most use cases, but not all.
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

# unset & re-source system profile
bd_start() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_start_arg="${1}"
    [ ${#bd_start_arg} -gt 0 ] && bd_debug "bd_start_arg=${bd_start_arg}" 2

    # what now?

    return 0
}

# return 0 if 1, true, or yes
bd_true() {
    bd_debug "${FUNCNAME}(${@})" 55

    if [ "${1}" == '1' ] || [ "${1}" == 'true' ] || [ "${1}" == 'yes' ]; then
        return 0
    else
        return 1
    fi
}

# unset functions & variables
bd_unset() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_unset_start="${1}"

    local bd_unset_alias_name bd_unset_alias_names=()
    local bd_unset_function_name bd_unset_function_names=()
    local bd_unset_variable_name bd_unset_variable_names=()

    if [ "${bd_unset_start}" == 'start' ]; then
        # start

        # aliases
        bd_unset_alias_names+=(bd)
        bd_unset_alias_names+=(bd-ansi)
        bd_unset_alias_names+=(bd-debug)

        for bd_unset_alias_name in ${bd_unset_alias_names[@]}; do
            alias "${bd_unset_alias_name}" &> /dev/null && unalias "${bd_unset_alias_name}"
        done
        unset -v bd_unset_alias_name

        # variables
        local bd_unset_variable bd_unset_variable_name bd_unset_oifs
        bd_unset_oifs="${IFS}"
        IFS=$'\n'
        for bd_unset_variable in $(declare -g 2> /dev/null); do
            if [[ "${bd_unset_variable}" == 'BD_'*'='* ]]; then
                bd_unset_variable_name="${bd_unset_variable%%=*}"

                # don't unset exclusives
                bd_exclusive_variable "${bd_unset_variable_name}" && continue

                # don't unset these, either
                [ "${bd_unset_variable_name}" == 'BD_BASH_INIT_FILE' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_DEBUG' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_HOME' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_LEARN' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_MAIN' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_SOURCE' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_USER' ] && continue
                [ "${bd_unset_variable_name}" == 'BD_VERSION' ] && continue

                [[ "${bd_unset_variable_name}" == 'BD_'*'EXPORT'* ]] && continue

                if [ "${bd_unset_variable_name}" == 'BD_AUTOLOAD_DIRS' ]; then
                    if ! bd_true ${BD_LEARN}; then
                        bd_unset_variable_names+=("${bd_unset_variable_name}")
                    fi
                else
                    bd_unset_variable_names+=("${bd_unset_variable_name}")
                fi
            fi
        done
        IFS="${bd_unset_oifs}"
        unset -v bd_unset_variable bd_unset_variable_name bd_unset_oifs
    else
        # finish

        # functions
        bd_unset_function_names+=(bd_aliases)
        bd_unset_function_names+=(bd_ansi_chart)
        bd_unset_function_names+=(bd_ansi_chart_16)
        bd_unset_function_names+=(bd_ansi_chart_16_bg)
        bd_unset_function_names+=(bd_ansi_chart_16_fg)
        bd_unset_function_names+=(bd_ansi_chart_256)
        bd_unset_function_names+=(bd_ansi_chart_256_bg)
        bd_unset_function_names+=(bd_ansi_chart_256_fg)
        bd_unset_function_names+=(bd_autoload)
        bd_unset_function_names+=(bd_autoload_dir)
        bd_unset_function_names+=(bd_exclusive_variable)
        bd_unset_function_names+=(bd_load)
        bd_unset_function_names+=(bd_load_config_dir)
        bd_unset_function_names+=(bd_load_config_file)
        bd_unset_function_names+=(bd_load_config_files)
        bd_unset_function_names+=(bd_realpath)
        bd_unset_function_names+=(bd_start)
        bd_unset_function_names+=(bd_upgrade)
        bd_unset_function_names+=(bd_uptime)

        for bd_unset_function_name in ${bd_unset_function_names[@]}; do
            unset -f "${bd_unset_function_name}"
        done
        unset -v bd_unset_function_name

        # variables
        bd_unset_variable_names+=(BD_ANSI_SOURCED)
        bd_unset_variable_names+=(BD_AUTOLOAD_DEFAULT_DIR)
        bd_unset_variable_names+=(BD_CONFIG_FILE)
        bd_unset_variable_names+=(BD_MAIN)
    fi

    for bd_unset_variable_name in ${bd_unset_variable_names[@]}; do
        bd_debug "unset -v ${bd_unset_variable_name}" 5
        unset -v ${bd_unset_variable_name}
    done
    unset -v bd_unset_variable_name

    if [ "${bd_unset_start}" != 'start' ]; then
        # finish
        if ! bd_true ${BD_ANSI_EXPORT}; then
            unset -f bd_ansi
        fi

        if ! bd_true ${BD_DEBUG_EXPORT}; then
            unset -f bd_debug bd_debug_ms
        fi

        unset -f bd_true bd_unset
    fi

    unset -v bd_unset_alias_name bd_unset_alias_names
    unset -v bd_unset_function_name bd_unset_function_names
    unset -v bd_unset_variable_name bd_unset_variable_names
}

# upgrade to the latest version of bd.sh (WIP)
bd_upgrade() {
    bd_debug "${FUNCNAME}(${@})" 55

    local bd_upgrade_dir_name="${1}"

    if type -P git &> /dev/null; then
        if [ -d "${bd_upgrade_dir_name}" ] && [ -r "${bd_upgrade_dir_name}" ]; then
            [ "${bd_upgrade_dir_name}" == "${BD_DIR}" ] && echo "BD_DIR = ${BD_DIR}" && echo

            local bd_upgrade_pwd="${PWD}"

            cd "${bd_upgrade_dir_name}"

            if [ -d .git ] && [ -r .git ]; then
                git remote -v && echo && git pull && echo
            fi

            cd "${bd_upgrade_pwd}"

            unset -v bd_upgrade_pwd
        fi
    else
        echo; echo 'git not found'; echo
    fi
}

# output milliseconds since uptime (used for debugging)
bd_uptime() {
    bd_debug "${FUNCNAME}(${@})" 55

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
            bd_uptime_t0="$(sysctl -n kern.boottime 2> /dev/null)"
            bd_uptime_t1="${bd_uptime_t0%,*}"
            bd_uptime_t1="${bd_uptime_t1##* }"
            bd_uptime_ms=$((($(date +%s)-${bd_uptime_t1})*1000))
        fi
    fi

    printf "${bd_uptime_ms}"
}

#
# bootstrap
#

export BD_DEBUG=${BD_DEBUG:-0} # level >0 enables debugging

export BD_SOURCE="$(bd_realpath "${BASH_SOURCE}")"

#
# options
#

# functions argument (first, otherwise embedded functions will be unset)
if [ "${1}" == 'f' ] || [[ "${1}" == 'function'* ]]; then
    return $?
fi

# dir argument
if [ "${1}" == 'd' ] || [[ "${1}" == 'dir'* ]]; then
    bd_load_config_files preload

    echo "${BD_AUTOLOAD_DIRS[@]}"

    bd_unset finish

    return 0
fi

# env argument
if [ "${1}" == 'e' ] || [[ "${1}" == 'env'* ]]; then
    bd_debug "${BD_SOURCE} env" 1

    bd_load_config_files preload

    BD_OIFS="${IFS}"
    IFS=$'\n'
    for BD_DECLARE in $(declare -g 2> /dev/null); do
        if [[ "${BD_DECLARE}" == 'BD_'*'='* ]]; then
            BD_VARIABLE_NAME="${BD_DECLARE%%=*}"

            # don't show these
            bd_exclusive_variable "${BD_VARIABLE_NAME}" && continue

            printf "%-30s" "${BD_VARIABLE_NAME}"
            printf " = "
            if [ "${BD_VARIABLE_NAME}" == 'BD_AUTOLOAD_DIRS' ]; then
                echo "${BD_AUTOLOAD_DIRS[@]}"
            else
                echo "${!BD_VARIABLE_NAME}"
            fi
        fi
    done
    IFS="${BD_OIFS}"
    unset -v BD_DECLARE BD_OIFS BD_VARIABLE_NAME

    bd_unset finish

    return $?
fi

# license argument
if [ "${1}" == 'l' ] || [[ "${1}" == 'license'* ]]; then
    bd_debug "${BD_SOURCE} license" 1

    bd_load_config_files preload

    # if it's readable then display the included license
    if [ -r "${BD_DIR}/bin/bd-license" ]; then
        if [ -x "${BD_DIR}/bin/bd-license" ]; then
            "${BD_DIR}/bin/bd-license"
        else
            BD_ECHO_LICENSE=1 source "${BD_DIR}/bin/bd-license"
        fi
    else
        printf "\n'${BD_DIR}/bin/bd-license' file not found readable; see https://github.com/bash-d/bd/blob/main/LICENSE.md\n\n"

        return 1
    fi

    bd_unset finish

    return 0
fi

# pull/up arguments
if [ "${1}" == 'p' ] || [[ "${1}" == 'pull'* ]] || [ "${1}" == 'u' ] || [[ "${1}" == 'up'* ]]; then
    bd_debug "${BD_SOURCE} upgrade" 1

    bd_load_config_files preload

    [ ! -O "${BD_SOURCE}" ] && printf "\nrun 'bd ${1}' as the owner of ${BD_SOURCE} ...\n\n" && ls -l "${BD_SOURCE}" && echo && return 1

    bd_upgrade "${BD_DIR}"

    bd_unset finish

    return $?
fi

# default/restart/start arguments
if [ "${1}" == '' ] || [ "${1}" == 'restart' ] || [ "${1}" == 'start' ]; then
    bd_debug "${BD_SOURCE} start" 1

    if bd_start ${@}; then
        bd_debug "${BD_SOURCE} bd_start ${@} rc=0" 1
        # success; continue to main (do not return!)
    else
        # bd_start sent a non-zero rc; do not proceed
        return 1
    fi
fi

#
# main
#

bd_debug "${BD_SOURCE} main started"

export BD_MAIN=1

#
# unset (most of the) included bd- aliases, bd_ functions, & BD_ variables
#

bd_unset start

#
# (re)set BD_ config variables (after bd_unset start)
#

bd_debug "BD_SOURCE = ${BD_SOURCE}" 2

export BD_DIR="${BD_SOURCE%/*}"

bd_debug "BD_DIR = ${BD_DIR}" 2

if [ ${#BD_DIR} -gt 0 ] && [ -d "${BD_DIR}" ] && type -P git &> /dev/null; then
    BD_GIT_URL="$(cd "${BD_DIR}" && git remote get-url $(git remote 2> /dev/null) 2> /dev/null)"
fi
[ ${#BD_GIT_URL} -eq 0 ] && BD_GIT_URL="https://github.com/bash-d/bd"

export BD_GIT_URL

bd_debug "BD_GIT_URL = ${BD_GIT_URL}" 2

#
# preload config files
#

bd_load_config_files preload

#
# determine operating system; set BD_OS variables
#

export BD_OS='unknown'

if type -P uname &> /dev/null; then
    BD_OS_KERNEL_NAME="$(uname -s 2> /dev/null)"

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

bd_debug "BD_OS = ${BD_OS}" 1

if [ ${#BD_DEBUG} -gt 0 ]; then
    export BD_START_TIME=$(bd_uptime)
fi

#
# ensure BD_AUTOLOAD_DIRS, BD_AUTOLOAD_CONFIG_DIRS, BD_BASH_INIT_FILE, BD_HOME, BD_USER, & USER; (WIP)
#

unset -v BD_AUTOLOAD_CONFIG_DIRS

# TODO: learn requires more testing
bd_true ${BD_LEARN} || BD_AUTOLOAD_DIRS=()

[ "${EUID}" == '0' ] && USER=root

[ "${USER}" != 'root' ] && unset BD_USER # honor sudo --preserve-env=BD_USER

# preferred order of sources for BD_USER
[ ${#BD_USER} -eq 0 ] && [ "${USER}" == 'root' ] && type -P logname &> /dev/null && BD_USER=$(logname 2> /dev/null) # hack; only use logname for root?
[ ${#BD_USER} -eq 0 ] && [ ${#USER} -gt 0 ] && BD_USER=${USER} # default to ${USER}
[ ${#BD_USER} -eq 0 ] && [ ${#USERNAME} -gt 0 ] && BD_USER=${USERNAME}
[ ${#BD_USER} -eq 0 ] && type -P who &> /dev/null && BD_USER=$(who -m 2> /dev/null)
[ ${#BD_USER} -eq 0 ] && [ ${#SUDO_USER} -gt 0 ] && BD_USER=${SUDO_USER}
[ ${#BD_USER} -eq 0 ] && [ ${#LOGNAME} -gt 0 ] && BD_USER=${LOGNAME}

[ ${#USER} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && USER=${BD_USER}

[ "${USER}" != 'root' ] && unset BD_HOME # honor sudo --preserve-env=BD_HOME

[ ${#BD_USER} -eq 0 ] && BD_HOME="/tmp"

# preferred order of sources for BD_HOME
[ ${#BD_HOME} -eq 0 ] && [ ${#HOME} -gt 0 ] && BD_HOME=${HOME} # default to ${HOME}
[ ${#BD_HOME} -eq 0 ] && [ ${#BD_USER} -gt 0 ] && type -P getent &> /dev/null && BD_HOME=$(getent passwd ${BD_USER} 2> /dev/null) && BD_HOME=${BD_HOME%%:*}
[ ${#BD_HOME} -eq 0 ] && BD_HOME="~"

if shopt -q login_shell; then
    # login shell
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"
    [ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r ~/.bash_profile ] && BD_BASH_INIT_FILE=~/.bash_profile
fi

# not a login shell, or it is a login shell and there's no ~/.bash_profile
[ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bashrc" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bashrc"
[ ${#BD_BASH_INIT_FILE} -eq 0 ] && [ -r "${BD_HOME}/.bash_profile" ] && BD_BASH_INIT_FILE="${BD_HOME}/.bash_profile"

export BD_BASH_INIT_FILE

#
# load config files
#

bd_load_config_files
bd_debug "BD_AUTOLOAD_DIRS = ${BD_AUTOLOAD_DIRS[@]} (bd_load_config_files)" 1

#
# set dynamic aliases & bd() function
#

if [ ${#BD_SOURCE} -gt 0 ] && [ -r "${BD_SOURCE}" ]; then
    bd() { 
        local bd_help=''
        bd_help+="\n"
        bd_help+="usage: bd [option]\n"
        bd_help+="\n"
        bd_help+="options:\n"
        bd_help+="\n"
        bd_help+="  ['' | restart | start]          - (default) invoke autoloader & unset bd_functions\n"
        bd_help+="\n"
        bd_help+="  env                             - display all declared BD_ environment variables & values\n"
        bd_help+="\n"
        bd_help+="  dirs                            - display only BD_AUTOLOAD_DIRS array values\n"
        bd_help+="  license                         - display license\n"
        bd_help+="  pull                            - upgrade; pull latest version of bd from "
        if [ ${#BD_GIT_URL} -gt 0 ]; then
            bd_help+="${BD_GIT_URL}"
        else
            bd_help+="GitHub"
        fi
        bd_help+="\n"
        bd_help+="\n"
        bd_help+="  functions                       - export all bd_ functions; do not invoke autoloader\n"
        bd_help+="                                    (e.g. for unit testing, or to use in other scripts)\n"
        bd_help+="\n"
        bd_help+="  [help | --help | -h]            - this message\n"
        bd_help+="\n"

        case "${1}" in 
            help|h|--help|-h)
                printf "${bd_help}"
                return
                ;;
            *)
                source "${BD_SOURCE}"
                ;;
        esac
    }
fi

bd_aliases

#
# autoload directories
#

bd_autoload "${BD_AUTOLOAD_DIRS[@]}"

if [ ${#BD_DEBUG} -gt 0 ]; then
    export BD_FINISH_TIME=$(bd_uptime 2> /dev/null)
    [[ "${BD_START_TIME}" =~ ^[0-9]+$ ]] && [[ "${BD_FINISH_TIME}" =~ ^[0-9]+$ ]] && BD_TOTAL_TIME=$((${BD_FINISH_TIME}-${BD_START_TIME}))
    export BD_TOTAL_TIME_MS="$(bd_debug_ms ${BD_TOTAL_TIME} 2> /dev/null)"

    bd_debug "${BD_SOURCE} main finished ${BD_TOTAL_TIME_MS}" 0

    unset -v BD_FINISH_TIME BD_START_TIME BD_TOTAL_TIME BD_TOTAL_TIME_MS
fi

#
# unset ephemeral bd_ functions & BD_ variables
#

bd_unset finished
