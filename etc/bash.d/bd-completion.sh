# bd-com-pletion.sh: bash completion for bd

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

# bash completion for bd
_bd_completion() {
    if [ "${COMP_WORDS[0]}" == "bd" ]; then
        local _bd_completion_action _bd_completion_option
        local _bd_completion_words
        local _bd_completion_word # cur

        _bd_completion_words="bits dir env functions help license upgrade"

        _bd_completion_word="${COMP_WORDS[COMP_CWORD]}"

        if [ $COMP_CWORD -gt 1 ]; then
            _bd_completion_option=${COMP_WORDS[1]}
        fi

        if [ $COMP_CWORD -gt 2 ]; then
            _bd_completion_action=${COMP_WORDS[2]}
        fi

        case "${_bd_completion_option}" in
            bits|b|--bits|-b)
                #echo _bd_completion_option=$_bd_completion_option _bd_completion_action=$_bd_completion_action, _bd_completion_word=$_bd_completion_word, 3=${COMP_WORDS[3]}

                if [ "${_bd_completion_action}" == "" ]; then
                    _bd_completion_words="get hash ls rm"
                    COMPREPLY=($( compgen -W "${_bd_completion_words}" -- ${_bd_completion_word} ))
                    return
                fi

                if [ "${COMP_WORDS[3]}" == "" ] && [ "${_bd_completion_action}" == "rm" ]; then
                    BD_BITS_DIR="${BD_BITS_DIR:-${BD_DIR}/etc/bash.d/bits}"
                    COMPREPLY=($(compgen -W "$(command ls ${BD_BITS_DIR})" -- "${_bd_completion_word}"))
                    return
                fi
                ;;
            dir*|d|--dir*|-d)
                if [ "${_bd_completion_action}" == "" ]; then
                    _bd_completion_words="hash ls"
                    COMPREPLY=($( compgen -W "${_bd_completion_words}" -- ${_bd_completion_word} ))
                    return
                fi
                ;;
            env*|e|--env|-e)
                if [ "${_bd_completion_action}" == "" ]; then
                    _bd_completion_words="$(bd env | cut -d' ' -f1)"
                    COMPREPLY=($( compgen -W "${_bd_completion_words}" -- ${_bd_completion_word} ))
                    return
                fi
                ;;
            functions|--functions)
                ;;
            help|h|--help|-h)
                ;;
            license|--license)
                ;;
            "")
                COMPREPLY=($( compgen -W "${_bd_completion_words}" -- ${_bd_completion_word} ))
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    fi
}
complete -F _bd_completion bd
