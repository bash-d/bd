# 0.46.1.1
- bd.sh: don't unset BD_PROMPT_HOOK

# 0.46.1
- bd.sh: don't unset BD_CLIPBOARD
- etc/bash.d/bd-root.sh: preserve WAYLAND_DISPLAY
- etc/bash.d/bd-root.sh: preserve BD_CLIPBOARD
- example/.bashrc: source /etc/profile

# 0.46.0
-  bd.sh: allow setting BD_SUB_DIR
-  bd.sh: renamed BD_AUTOLOADER_SUB_DIR to BD_SUB_DIR
-  bd.sh: started considering lazy loading, like ksh/zsh autoload
-  bd.sh: etc/bash.d/bd-help.sh: removed; moved into bd.sh
-  bd.sh: renamed bd_autoload* to bd_autoloader*
-  all: renamed BD_AUTOLOAD_* to BD_AUTOLAODER_* 0.45.1

# 0.45.1
- all: renamed 'snippets' to 'bits'

# 0.45.0
- all: all functions are now prefixed with _bd_ except bd()
- all: embed MIT license text
- all: began adopting some of [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- bd.sh: renamed BD_AUTOLOAD_DEFAULT_DIR to BD_AUTOLOAD_SUB_DIR
- bd.sh: added support for 'install' option
- bd.sh: no more aliases at all. only unset bd alias if it exists.
- etc/bash.d/bd-deprecated.sh: deprecated bd-ansi() and bd-debug()
- etc/bash.d/bd-completion.sh: added
- etc/bash.d/bd-deprecated.sh: added
- etc/bash.d/bd-option.sh: added
- etc/bash.d/bd-option-help.sh: added
- etc/bash.d/bd-option-license.sh: added
- etc/bash.d/bd-option-snippet.sh: added
- etc/bash.d/bd-option-upgrade.sh: added
- example/.bashrc: renamed
- example/.bash_profile: renamed
- example/.bd.conf: added

# 0.44.1
- all: do not use set -a; use explicit exports

# 0.44.0 (breaking)

- all: removed metadata
- all: use set -a rather than explicit exports
- 00bd.sh: removed; change all references to bd.sh

# 0.43.0
- bd.sh: renamed 00bd.sh to bd.sh
- bd.sh: removed BD_ID; use BASH_ARGC to prevent recursion
- bd.sh: lower debug level required to display the full BD_SOURCE path (1=basename, >=2=full path)
- bd.sh: bd_debug() outputs to stderr
- bd.sh: bd_realpath() now looks for realpath & readlink before resorting to bash hack
- bd.sh: bd() no longer sources /etc/profile and/or /etc/bashrc; leave that to ~/.bashrc (etc)
- bd.sh: set BD_GIT_URL
- 00bd.sh: replaced with symbolic link

# 0.42.3
- 00bd.sh: renamed *config_bag* to *bag_config*
- bin/bd-install: functional prototype

# 0.42.2
- 00bd.sh: bd() option argument handling, help, and automatically setting BD_GIT_URL

# 0.42.1
- 00bd.sh: change bd alias to bd() function

# 0.42.0

- 00bd.sh: don't use function keyword
- bin/bd-ansi: don't use function keyword
- etc/bash.d/bd-ansi.sh: don't use function keyword

# 0.41.0

- 00bd.sh: significant changes to main logic
- 00bd.sh: always test if a directory or file is readable
- 00bd.sh: bd_config_files preload & bd_unset_finish for all arguments except functions
- 00bd.sh: don't unset BD_*EXPORT* variables that were set in the parent environment (e.g. via .bashrc)
- 00bd.sh: expand (replace) ~ in config files
- 00bd.sh: revised bd_ansi stub logic
- 00bd.sh: bd_bag() removed
- 00bd.sh: bd_bagger() renamed to bd_bag()
- 00bd.sh: support BD_ANSI_SOURCED (interally)
- 00bd.sh: bd_config_files() added
- 00bd.sh: bd_exclusive_variables() added
- bash.d/ moved to etc/bash.d/
- etc/bash.d/bd-ansi.sh: comments
- etc/bash.d/bd-ansi.sh: support TERM=screen* and TERM=*tmux*
- etc/bash.d/bd-ansi.sh: prevent loading multiple times; export BD_ANSI_SOURCED=1
- etc/bash.d/bd-os.sh: comments
- etc/bash.d/bd-root.sh: comments
- etc/bash.d/bd-root.sh: bd-root-profile alias renamed to bd-root-login
- bin/bd-ansi: source moved etc/bash.d/bd-ansi.sh

# 0.40.2

- 00bd.sh: significant changes to main logic & bootstrap order of operation
- 00bd.sh: stop supporting .bash.d.conf
- 00bd.sh: support (multiple) config files (${BD_DIR}/.bd.conf, /etc/bd.conf, ${HOME}/.bd.conf, ${BD_HOME}/.bd.conf, ${PWD}/.bd.conf)
- 00bd.sh: support adding multiple, custom BD_BAG_DIR directories via config file(s)
- 00bd.sh: support setting & automatically exporting custom BD_* variables via config file(s)
- 00bd.sh: support 'bd env' argument
- 00bd.sh: support 'bd pull/update/upgrade' argument aliases
- 00bd.sh: support 'bd reload/restart/start' argument aliases
- 00bd.sh: support BD_ANSI_EXPORT=1 and BD_DEBUG_EXPORT=1 to leave the bd_ansi() & bd_debug() functions exported to the environment
- 00bd.sh: support BD_LEARN=1 to prevent unsetting BD_BAG_DIRS every time (WIP)
- 00bd.sh: test login/non-login shell to determine whether to source .bash_profile or .bashrc
- 00bd.sh: test variable lengths versus empty strings
- 00bd.sh: increase all function debug levels to 55
- 00bd.sh: more comments
- 00bd.sh: more consistent variable naming
- 00bd.sh: use single quotes when appropriate
- 00bd.sh: bd_aliases() logic changed
- 00bd.sh: bd_ansi() is now exported for the duration of main
- 00bd.sh: bd_bagger() increase some debug levels (less noise at low levels)
- 00bd.sh: bd_config_bag_dirs() added
- 00bd.sh: bd_config_file() replaced bd_bagger_file()
- 00bd.sh: bd_debug() doesn't complain if bd_ansi isn't found
- 00bd.sh: bd_debug() is now exported for the duration of main
- 00bd.sh: bd_reload() renamed to bd_start()
- 00bd.sh: bd_true() added
- 00bd.sh: bd_unset() logic changed
- 00bd.sh: bd_upgrade() now only supports git (pull)
- 00bd.sh: bd_uptime_ms() renamed to bd_uptime()
- .bashrc: example
- .bash_profile: example
- bash.d/bd-active.sh: removed
- bash.d/bd-ansi.sh: support xterm
- bash.d/bd-ansi.sh: export bd_ansi()
- bash.d/bd-os.sh: support BD_OS_ID=cygwin
- bash.d/bd-root.sh: preserve SSH_AUTH_SOCK if it's set
- bash.d/bd-root.sh: don't preserve BD_BASH_INIT_FILE
- bash.d/bd-root.sh: test for executable su
- bin/bd-ansi: exit if BD_DIR is not set or readable
- bin/bd-debug: exit if BD_DIR is not set or readable

# 0.40.1

- fix regression; honor BD_ANSI_EXPORT [to export bd_ansi()]

# 0.40.0

- handle arguments differently
- handle missing functions better
- add bd-ansi alias & executable wrapper
- add bd-debug alias & executable wrapper
- rename bd_load*() to bd_autoload*()
- different debug colors for levels 0-9
- localize BD_LC_COLLATE
- change embedded bag dir from 'bd' to 'bash.d'
- automatically bag all subdirectories in $BD_HOME/etc/bash.d (and $HOME/etc/bash.d)
- add bd_unset() & unset all bd_* functions after loading
- bd update now pulls from git repo (if .git dir exists)
- add bd env argument
- add bd license argument
- add bd functions argument
- add BD_BASH_INIT_FILE, BD_SOURCE, & BD_DIR exports
- add BD_*_SH exports
- support .bd.conf or .bash.d.conf files
- add bd-root.sh which automatically sets bd-root & bd-root-profile aliases
- add bin/bd-ansi executable wrapper for bd_ansi()
- add bin/bd-debug executable wrapper for bd_debug()
- add bin/bd-license
- updated license
