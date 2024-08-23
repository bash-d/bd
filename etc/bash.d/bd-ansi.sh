# bd-ansi.sh: display a message that's ansi colorized/formatted

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

# DO NOT USE bd-debug or bd_debug() inside this script!

#
# init
#

# prevent non-sourced execution
if [ "${0}" == "${BASH_SOURCE}" ]; then
    printf "\n${BASH_SOURCE} | ERROR | this code is not designed to be executed (instead, 'source ${BASH_SOURCE}')\n\n"
    exit 1
fi

# prevent loading multiple times
[ "${BD_ANSI_SOURCED}" == "1" ] && return

# exit/return for terms that may not support following functions
case "${TERM}" in
    alacritty*|ansi*|*color|screen*|*tmux*|*xterm*)
        ;;
    *)
        if [ "${0}" == "${BASH_SOURCE}" ]; then
            exit
        else
            return
        fi
esac

#
# functions
#

# echo ansi codes using common names
_bd_ansi() {
    local bd_ansi="${1}"

    [ ${#bd_ansi} -eq 0 ] && return 0

    # https://en.wikipedia.org/wiki/ANSI_escape_code

    local bd_ansi_reset_all
    bd_ansi_reset_all='\e[0m' # reset all attributes

    case ${bd_ansi} in
        bold) echo -ne '\e[1m' ;;
        dim) echo -ne '\e[2m' ;;
        italic|italics) echo -ne '\e[3m' ;;
        underline) echo -ne '\e[4m' ;;
        blink) echo -ne '\e[5m' ;;
        blink_slow) echo -ne '\e[5m' ;;
        blink_fast) echo -ne '\e[6m' ;;
        reverse) echo -ne '\e[7m' ;;
        hidden) echo -ne '\e[8m' ;;

        reset) echo -ne "${bd_ansi_reset_all}" ;;
        reset_all) echo -ne "${bd_ansi_reset_all}" ;;
        reset_bold) echo -ne '\e[21m' ;;
        reset_dim) echo -ne '\e[22m' ;;
        reset_italic|reset_italics) echo -ne '\e[23m' ;;
        reset_underline) echo -ne '\e[24m' ;;
        reset_blink) echo -ne '\e[25m' ;;
        reset_reverse) echo -ne '\e[27m' ;;
        reset_hidden) echo -ne '\e[28m' ;;

        fg_default) echo -ne '\e[39m' ;;
        bg_default) echo -ne '\e[49m' ;;

        # colors 1 and 2 always use the sgr pallet

        # black names are low intensity to high intensity

        # standard 0 (black)
        fg_black1|fg_black|black) echo -ne '\e[30m' ;; # FG Black
        fg_black2|fg_bright_black) echo -ne '\e[90m' ;; # FG Bright Black (Gray)

        bg_black1|bg_black) echo -ne '\e[40m' ;; # BG Black
        bg_black2|bg_bright_black) echo -ne '\e[100m' ;; # BG Bright Black (Gray)

        # all other color names are high intensity to low intensity; colors greather than 2 use the 256 pallet

        # standard 1 (red)
        fg_red1|fg_bright_red|bright_red) echo -ne '\e[91m' ;; # FG Bright Red
        fg_red2|fg_red|red) echo -ne '\e[31m' ;; # FG Red
        fg_red3) echo -ne '\e[38;5;124m' ;;
        fg_red4) echo -ne '\e[38;5;88m' ;;
        fg_red5) echo -ne '\e[38;5;52m' ;;

        bg_red1|bg_bright_red) echo -ne '\e[101m' ;; # BG Bright Red
        bg_red2|bg_red) echo -ne '\e[41m' ;; # BG Red
        bg_red3) echo -ne '\e[48;5;124m' ;;
        bg_red4) echo -ne '\e[48;5;88m' ;;
        bg_red5) echo -ne '\e[48;5;52m' ;;

        # standard 2 (green)
        fg_green1|fg_bright_green|bright_green) echo -ne '\e[92m' ;; # FG Bright Green
        fg_green2|fg_green|green) echo -ne '\e[32m' ;; # FG Green
        fg_green3) echo -ne '\e[38;5;28m' ;;
        fg_green4) echo -ne '\e[38;5;22m' ;;
        fg_green5) echo -ne '\e[38;5;58m' ;;

        bg_green1|bg_bright_green) echo -ne '\e[102m' ;; # BG Bright Green
        bg_green2|bg_green) echo -ne '\e[42m' ;; # BG Green
        bg_green3) echo -ne '\e[48;5;28m' ;;
        bg_green4) echo -ne '\e[48;5;22m' ;;
        bg_green5) echo -ne '\e[48;5;58m' ;;

        # standard 3 (yellow)
        fg_yellow1|fg_bright_yellow|bright_yellow) echo -ne '\e[93m' ;;
        fg_yellow2|fg_yellow|yellow) echo -ne '\e[33m' ;;
        fg_yellow3) echo -ne '\e[38;5;178m' ;;
        fg_yellow4) echo -ne '\e[38;5;172m' ;;
        fg_yellow5) echo -ne '\e[38;5;136m' ;;

        bg_yellow1|bg_bright_yellow) echo -ne '\e[103m' ;;
        bg_yellow2|bg_yellow) echo -ne '\e[43m' ;;
        bg_yellow3) echo -ne '\e[48;5;178m' ;;
        bg_yellow4) echo -ne '\e[48;5;172m' ;;
        bg_yellow5) echo -ne '\e[48;5;136m' ;;

        # standard 4 (blue)
        fg_blue1|fg_bright_blue|bright_blue) echo -ne '\e[94m' ;;
        fg_blue2|fg_blue|blue) echo -ne '\e[34m' ;;
        fg_blue3) echo -ne '\e[38;5;20m' ;;
        fg_blue4) echo -ne '\e[38;5;19m' ;;
        fg_blue5) echo -ne '\e[38;5;18m' ;;

        bg_blue1|bg_bright_blue) echo -ne '\e[104m' ;;
        bg_blue2|bg_blue) echo -ne '\e[44m' ;;
        bg_blue3) echo -ne '\e[48;5;20m' ;;
        bg_blue4) echo -ne '\e[48;5;19m' ;;
        bg_blue5) echo -ne '\e[48;5;18m' ;;

        # standard 5 (magenta)
        fg_magenta1|fg_bright_magenta|bright_magenta) echo -ne '\e[95m' ;;
        fg_magenta2|fg_magenta|magenta) echo -ne '\e[35m' ;;
        fg_magenta3) echo -ne '\e[38;5;90m' ;;
        fg_magenta4) echo -ne '\e[38;5;91m' ;;
        fg_magenta5) echo -ne '\e[38;5;55m' ;;

        bg_magenta1|bg_bright_magenta) echo -ne '\e[105m' ;;
        bg_magenta2|bg_magenta) echo -ne '\e[45m' ;;
        bg_magenta3) echo -ne '\e[48;5;90m' ;;
        bg_magenta4) echo -ne '\e[48;5;91m' ;;
        bg_magenta5) echo -ne '\e[48;5;55m' ;;

        # standard 6 (cyan)
        fg_cyan1|fg_bright_cyan|bright_cyan) echo -ne '\e[96m' ;;
        fg_cyan2|fg_cyan|cyan) echo -ne '\e[36m' ;;
        fg_cyan3) echo -ne '\e[38;5;37m' ;;
        fg_cyan4) echo -ne '\e[38;5;30m' ;;
        fg_cyan5) echo -ne '\e[38;5;23m' ;;

        bg_cyan1|bg_bright_cyan) echo -ne '\e[106m' ;;
        bg_cyan2|bg_cyan) echo -ne '\e[46m' ;;
        bg_cyan3) echo -ne '\e[48;5;37m' ;;
        bg_cyan4) echo -ne '\e[48;5;30m' ;;
        bg_cyan5) echo -ne '\e[48;5;23m' ;;

        # standard 7 (white)
        fg_white1|fg_bright_white|bright_white) echo -ne '\e[97m' ;;
        fg_white2|fg_white|white) echo -ne '\e[37m' ;;
        fg_white3) echo -ne '\e[38;5;252m' ;;
        fg_white4) echo -ne '\e[38;5;251m' ;;
        fg_white5) echo -ne '\e[38;5;250m' ;;

        bg_white1|bg_bright_white) echo -ne '\e[107m' ;;
        bg_white2|bg_white) echo -ne '\e[47m' ;;
        bg_white3) echo -ne '\e[48;5;252m' ;;
        bg_white4) echo -ne '\e[48;5;251m' ;;
        bg_white5) echo -ne '\e[48;5;250m' ;;

        # standard 8 (gray)
        fg_gray1|fg_bright_gray|bright_gray|fg_grey1|fg_bright_grey|bright_grey) echo -ne '\e[38;5;249m' ;;
        fg_gray2|fg_gray|gray|fg_grey2|fg_grey|grey) echo -ne '\e[38;5;246m' ;;
        fg_gray3|fg_grey3) echo -ne '\e[38;5;243m' ;;
        fg_gray4|fg_grey4) echo -ne '\e[38;5;240m' ;;
        fg_gray5|fg_grey5) echo -ne '\e[38;5;237m' ;;

        bg_gray1|bg_gray|bg_grey1|bg_grey) echo -ne '\e[48;5;249m' ;;
        bg_gray2|bg_grey2) echo -ne '\e[48;5;246m' ;;
        bg_gray3|bg_grey3) echo -ne '\e[48;5;243m' ;;
        bg_gray4|bg_grey4) echo -ne '\e[48;5;240m' ;;
        bg_gray5|bg_grey5) echo -ne '\e[48;5;237m' ;;

        bg*) bd_ansi=${bd_ansi/bg/}; bd_ansi=${bd_ansi//_/}; [[ "${bd_ansi}" =~ ^[0-9]+$ ]] && echo -ne "\e[48;5;${bd_ansi}m" ;;

        fg*) bd_ansi=${bd_ansi/fg/}; bd_ansi=${bd_ansi//_/}; [[ "${bd_ansi}" =~ ^[0-9]+$ ]] && echo -ne "\e[38;5;${bd_ansi}m" ;;

        *)
            echo "${FUNCNAME} has no case for '${bd_ansi}'" 1>&2
            ;;
    esac

    if [ "${2}" != "" ]; then
        shift
        echo -n "${@}"
        echo -e "${bd_ansi_reset_all}"
    fi

    return 0
}

# display ansi color chart of common names
_bd_ansi_chart() {
    local bd_ansi_color_name
    local bd_ansi_color_names=()

    bd_ansi_color_names+=("fg_black1 fg_black black")
    bd_ansi_color_names+=("fg_black2 fg_bright_black")
    bd_ansi_color_names+=("bg_black1 bg_black")
    bd_ansi_color_names+=("bg_black2 bg_bright_black")
    bd_ansi_color_names+=("fg_red1 fg_bright_red bright_red fg_red2 fg_red red fg_red3 fg_red4 fg_red5")
    bd_ansi_color_names+=("bg_red1 bg_bright_red bg_red2 bg_red bg_red3 bg_red4 bg_red5")
    bd_ansi_color_names+=("fg_green1 fg_bright_green bright_green fg_green2 fg_green green fg_green3 fg_green4 fg_green5")
    bd_ansi_color_names+=("bg_green1 bg_bright_green bg_green2 bg_green bg_green3 bg_green4 bg_green5")
    bd_ansi_color_names+=("fg_yellow1 fg_bright_yellow bright_yellow fg_yellow2 fg_yellow yellow fg_yellow3 fg_yellow4 fg_yellow5")
    bd_ansi_color_names+=("bg_yellow1 bg_bright_yellow bg_yellow2 bg_yellow bg_yellow3 bg_yellow4 bg_yellow5")
    bd_ansi_color_names+=("fg_blue1 fg_bright_blue bright_blue fg_blue2 fg_blue blue fg_blue3 fg_blue4 fg_blue5")
    bd_ansi_color_names+=("bg_blue1 bg_bright_blue bg_blue2 bg_blue bg_blue3 bg_blue4 bg_blue5")
    bd_ansi_color_names+=("fg_magenta1 fg_bright_magenta bright_magenta fg_magenta2 fg_magenta magenta fg_magenta3 fg_magenta4 fg_magenta5")
    bd_ansi_color_names+=("bg_magenta1 bg_bright_magenta bg_magenta2 bg_magenta bg_magenta3 bg_magenta4 bg_magenta5")
    bd_ansi_color_names+=("fg_cyan1 fg_bright_cyan bright_cyan fg_cyan2 fg_cyan cyan fg_cyan3 fg_cyan4 fg_cyan5")
    bd_ansi_color_names+=("bg_cyan1 bg_bright_cyan bg_cyan2 bg_cyan bg_cyan3 bg_cyan4 bg_cyan5")
    bd_ansi_color_names+=("fg_white1 fg_bright_white bright_white fg_white2 fg_white white fg_white3 fg_white4 fg_white5")
    bd_ansi_color_names+=("bg_white1 bg_bright_white bg_white2 bg_white bg_white3 bg_white4 bg_white5")
    bd_ansi_color_names+=("fg_gray1 fg_bright_gray bright_gray fg_grey1 fg_bright_grey bright_grey fg_gray2 fg_gray gray fg_grey2 fg_grey grey fg_gray3 fg_grey3 fg_gray4 fg_grey4 fg_gray5 fg_grey5")
    bd_ansi_color_names+=("bg_gray1 bg_gray bg_grey1 bg_grey bg_gray2 bg_grey2 bg_gray3 bg_grey3 bg_gray4 bg_grey4 bg_gray5 bg_grey5")


    for bd_ansi_color_name in ${bd_ansi_color_names[@]}; do
        [ -z ${bd_ansi_color_name} ] && continue
        if [ "${1}" != "" ]; then
            if [[ "${bd_ansi_color_name}" != *"${1}"* ]]; then
                continue
            fi
        fi
        _bd_ansi ${bd_ansi_color_name} ${bd_ansi_color_name}
    done
}

# display full 16 color chart of echo -ne pastable strings
_bd_ansi_chart_16() {
    for bd_ansi_bg in {40..47} {100..107} 49; do
        for bd_ansi_fg in {30..37} {90..97} 39; do
            for bd_ansi_format in 0 1 2 4 5 7; do
                echo -ne "\e[${bd_ansi_format};${bd_ansi_bg};${bd_ansi_fg}m \\\e[${bd_ansi_format};${bd_ansi_bg};${bd_ansi_fg}m \e[0m"
            done
            echo
        done
        echo
    done
}

# display background 16 color chart of echo -ne pastable strings
_bd_ansi_chart_16_bg() {
    for bd_ansi_bg in {40..47} {100..107}; do
        echo -ne "\e[${bd_ansi_bg}m \\\e[${bd_ansi_bg}m \e[0m" && echo
    done
}

# display foreground 16 color chart of echo -ne pastable strings
_bd_ansi_chart_16_fg() {
    for bd_ansi_fg in {30..37} {90..97}; do
        echo -ne "\e[${bd_ansi_fg}m \\\e[${bd_ansi_fg}m \e[0m" && echo
    done
}

# display full 256 color chart of echo -ne pastable strings
_bd_ansi_chart_256() {
    _bd_ansi_chart_256_fg && echo && _bd_ansi_chart_256_bg
}

# display background 256 color chart of echo -ne pastable strings
_bd_ansi_chart_256_bg() {
    for bd_ansi_color in {0..255}; do
        echo -ne "\e[48;5;${bd_ansi_color}m \\\e[48;5;${bd_ansi_color}m \e[0m"
        if [ $(((${bd_ansi_color} + 1) % 6)) == 4 ]; then
            echo
        fi
    done
}

# display foreground 256 color chart of echo -ne pastable strings
_bd_ansi_chart_256_fg() {
    for bd_ansi_color in {0..255}; do
        echo -ne "\e[38;5;${bd_ansi_color}m \\\e[38;5;${bd_ansi_color}m \e[0m"
        if [ $(((${bd_ansi_color} + 1) % 6)) == 4 ]; then
            echo
        fi
    done
}

export BD_ANSI_SOURCED=1
