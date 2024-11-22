# bd.sh - The Bash Directory Autoloader

The Bash script, `bd.sh`, implements a sophisticated directory autoloader for managing Bash scripts and configurations.

## Purpose

`bd.sh` aims to streamline the management and dynamic sourcing of Bash scripts from predefined directories, ensuring reliability and flexibility for system-wide, user-specific, and project-specific configurations.

## Use Cases

* **Developers** - Manage project-specific Bash scripts without affecting the global environment.
* **System Administrators** - Automate the setup of consistent environments across users and systems.
* **Advanced Users** - Simplify and modularize their Bash configurations for better organization and maintainability.

## Notable Strengths

* Flexible and modular design.
* Clear emphasis on backward compatibility and robust error handling.
* Comprehensive debugging and logging support for troubleshooting.

## Key Features

### Autoloading Mechanism

* Sources additional Bash scripts (`.bash` or `.sh`) from specified directories, including:
	* User-specific - `~/.bash.d/`
	* Project-specific - `./etc/bash.d/`
	* System-wide - `/etc/bash.d/`
* Supports recursive execution for all files in these directories while maintaining order and avoiding duplicates.

### Namespace and Configuration Management

* Defines and resets namespaces to prevent variable and function collisions.
* Loads configuration variables (`BD_*`) from designated configuration files (`.bd.conf`), supporting customization at multiple levels (global, user, project).

### Dynamic Debugging Support

* Provides adjustable debugging levels via the `BD_DEBUG` variable.
* Outputs detailed logs, including timestamps and execution times, for debugging purposes.

### Compatibility and Robustness

* Ensures compatibility with different operating systems (Linux, macOS, Windows, & WSL).
* Handles edge cases like missing directories, invalid configurations, and unsupported environments.
* Implements safety checks to prevent direct execution and ensure only Bash-compatible shells execute the script.

### Utility Functions

* `_bd_autoload` - Starts the autoload procedure to predictably source files in the current shell.
* `_bd_debug` - Provides consistent, color-coded debug messages for improved readability.
* `_bd_os` - Determines the operating system & exports `BD_OS*` values for use in other scripts.
* `_bd_realpath` - A portable replacement for `realpath` or `readlink`.
* `_bd_true` - Interprets values like 1, true, or yes as logical true.
* `_bd_uptime` - Calculates uptime in milliseconds, used for performance metrics.

### Bootstrap and Initialization

* Sets up essential environment variables, including `BD_AUTOLOADER_DIRS`, `BD_HOME`, and `BD_USER`.
* Detects and initializes the appropriate directories and configurations based on the current shell environment.

### Error Handling and Safety

* Prevents execution in non-Bash shells.
* Includes graceful fallbacks for unsupported commands or missing features.
