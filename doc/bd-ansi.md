# `bd-ansi.sh`: ANSI Formatting for Enhanced Terminal Output

The `bd-ansi.sh` script is a complementary module for the `bd.sh` autoloader. It specializes in providing ANSI color and formatting utilities to enhance terminal output.

## Purpose

This script is a powerful utility for any terminal-based application or script, offering robust tools for creating visually enriched terminal outputs. It offers functions to generate ANSI escape codes for controlling text formatting, foreground/background colors, and styles in the terminal. It allows for rich, colorized output and improved debugging displays.

## Integration with `bd.sh`

* The script is loaded dynamically by `bd.sh` when required, particularly to provide enhanced colorized debug messages (`_bd_debug`).
* The `_bd_ansi` function can be called directly or indirectly within other utility scripts or debugging functions.

## Key Features

### Initialization and Safety Checks:

* Prevents direct execution; requires the script to be sourced (`source bd-ansi.sh`).
* Ensures compatibility by checking for terminal types that support ANSI escape sequences (alacritty, xterm, tmux, etc.).
* Avoids multiple loads by using the `BD_ANSI_SOURCED` flag.

### Core Functionality:

* `_bd_ansi`: The main function to generate and output ANSI codes for various styles and colors, supporting:
	* Text styles: bold, dim, italic, underline, blink, reverse, hidden
	* Reset options: Reset individual styles or all attributes.
	* Foreground colors: Black, red, green, yellow, blue, magenta, cyan, white, gray, and their bright variants.
	* Background colors: Same as foreground, with `bg_` prefixes.
* Supports extended 256-color palettes using the `fg<index>` and `bg<index>` notation.

### Color Charts:

* Provides functions to display ANSI color charts for reference or testing:
	* `_bd_ansi_chart`: Displays named color codes and their effects.
	* `_bd_ansi_chart_16`: Shows the 16-color standard palette.
	* `_bd_ansi_chart_16_fg`: Foreground colors in the 16-color palette.
	* `_bd_ansi_chart_16_bg`: Background colors in the 16-color palette.
	* `_bd_ansi_chart_256`: Full 256-color palette (foreground and background).

* Extended Support for Foreground and Background Colors:
	* Allows detailed color customization using the extended 256-color palette.
	* Provides multiple shorthand names for intuitive color reference.

## Use Cases

* Debugging and Logging:
	* Enhances readability of debug outputs by color-coding messages.

* User Feedback:
	* Produces visually distinct messages for warnings, errors, or success statuses.

* Terminal Testing:
	* Useful for testing terminal capabilities and ensuring color compatibility.

## Notable Strengths

* Comprehensive support for ANSI escape codes, including advanced palettes.
* Modular design makes it reusable across other scripts or projects.
* Simple interface for generating colorized outputs with descriptive names.
