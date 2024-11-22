# `bd-root.sh`  - Simplified Root Shell Access

The `bd-root.sh` script adds aliases for managing root-level shell access, in environments using the 'bash-d' system, without modifying the root profile.

## Purpose

This script is a practical tool for managing root-level operations in the `bash-d` system, offering convenience and ensuring seamless transitions between user contexts. It simplifies root-level operations by defining the `bd-root` and `bd-root-login` aliases. These aliases facilitate executing commands or starting a shell session as the root user while preserving the existing profile and essential environment variables.

## Use Cases

* **Developers** - Test scripts or configurations with root privileges while maintaining a consistent environment.
* **System Administrators** - Quickly transition between regular and root user environments without losing context.
* **Advanced Users** - Simplify and streamline administrative tasks requiring root access.

## Notable Strengths

* Flexible, with fallbacks for environments lacking `sudo`.
* Preserves critical environment variables to ensure session consistency.
* Simple and intuitive alias definitions.

## Integration with `bd.sh`

* Complements the broader `bash-d` system by providing streamlined root access for administrative tasks.
* Ensures that `BD_*` environment variables and initialization settings are preserved during privilege escalation.

## Key Features

### Initialization and Safety Checks

* Prevents direct execution, ensuring the script is only sourced (`source bd-root.sh`).
* Detects whether the current user is root to adjust behavior accordingly.

### Aliases for Root Access

* `bd-root` - Launches a root shell using bash with a specific initialization file.
* `bd-root-login` - Starts a full root login session.

### Environment Preservation

* Preserves critical environment variables (e.g., `BD_HOME`, `BD_USER`, `SSH_AUTH_SOCK`) when escalating privileges to root.
* Ensures custom variables (defined in `BD_ROOT_SUDO_PRESERVE_ENV`) are also included.

### Fallback Logic

* Uses `sudo` if available and correctly configured:
    * Checks for `NOPASSWD` permission to avoid unnecessary password prompts.
* Falls back to `su` if `sudo` is unavailable or not executable.
* If neither `sudo` nor `su` is available, the script defines basic aliases but may have limited functionality.

### Adaptation for Root User

* If already running as root, simplifies aliases to directly source the Bash initialization file (`bd-root`) or start a new session (`bd-root-login`).

### Automatic Path Detection

* Dynamically identifies the paths to `bash`, `sudo`, and `su` binaries.
* Ensures all required binaries are executable before creating aliases.

## Environment Variables Used

`BD_HOME` - Home directory for the `bash-d` system.
`BD_USER` - Username for the current user in the `bd` context.
`BD_BASH_INIT_FILE` - Initialization file for Bash (`.bash_profile` or `.bashrc`).
`BD_ROOT_SUDO_PRESERVE_ENV` - Additional environment variables to preserve when using `sudo`.

## Aliases Created

* `bd-root`:
    * For non-root users - Uses `sudo` or `su` to start a shell with the initialization file.
    * For root users - Sources the initialization file directly.
* `bd-root-login`:
    * For non-root users - Starts a full login session using `sudo` or `su`.
    * For root users - Same as `bd-root`.
