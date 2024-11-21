# `bd-os.sh`: Operating System Detection

The `bd-os.sh` script is a utility module designed to enhance the operating system detection capabilities of the `bd` environment.

## Purpose

This script is a practical tool for managing root-level operations in the `bash-d` system, offering convenience and ensuring seamless transitions between user contexts. It gathers and sets additional operating system details as environment variables (`BD_OS_*`). These details help tailor behavior or debugging output based on the underlying operating system.

## Integration with `bd.sh`

* Complements the `_bd_os` function in the main `bd.sh` script, enriching the base detection logic with more detailed and structured OS information.
* Provides detailed environment variables that other `bd` modules or user scripts can leverage.

## Key Features

### Initialization and Safety Checks:

* Ensures the script is sourced (`source bd-os.sh`) and not executed directly.
* Checks if the `BD_OS` variable is already set by the main `bd.sh` script; exits early if not.

### OS-Specific Detection Logic:

* Linux:
	* Reads from `/etc/os-release` to extract:
		* OS ID (`BD_OS_ID`), name, platform, variant, and version details.
	* On Enterprise Linux derivatives, falls back to `/etc/redhat-release` if `/etc/os-release` is unavailable.
	* Constructs major version information (BD_OS_VERSION_MAJOR) for further granularity.

* macOS (Darwin):
	* Uses `sw_vers` to retrieve:
		* Product name (`BD_OS_NAME`)
		* Build version (`BD_OS_VERSION`)
		* Product version (`BD_OS_VERSION_ID`)
	* Constructs a human-readable description (BD_OS_PRETTY_NAME).

* Windows:
	* Detects if the environment is running Cygwin and sets the BD_OS_ID accordingly.

* WSL (Windows Subsystem for Linux):
	* Appends {WSL} to BD_OS_PRETTY_NAME for easier identification.

### General Properties:

* Extracts additional details common to all platforms:
	* Machine architecture (`BD_OS_MACHINE`) using `uname -m`.
	* Constructs a path-like identifier (`BD_OS_PATH`) combining OS ID, major version, and architecture.

### Fallbacks:

* Defaults to `BD_OS_ID="unknown"` if no valid OS identification can be determined.

### Environment Variable Export:

* Exports the detected values for use by other `bd` components or scripts.

### Debugging Support:

* Uses `_bd_debug` to log the detected OS ID, aiding in troubleshooting.

## Environment Variables Set by the Script

`BD_OS`: Operating system base name (set by `bd.sh`).
`BD_OS_ID`: Detailed identifier for the OS (e.g., `darwin`, `rhel`, `ubuntu`).
`BD_OS_MACHINE`: Machine architecture (e.g., `x86_64`).
`BD_OS_NAME`: Human-readable name of the OS (e.g., `Fedora`).
`BD_OS_PATH`: Constructed path identifier (e.g., `ubuntu/22.04/x86_64`).
`BD_OS_PLATFORM_ID`: Platform-specific ID from `/etc/os-release`.
`BD_OS_PRETTY_NAME`: Comprehensive, user-friendly OS description (e.g., `Ubuntu 20.04.1 LTS`).
`BD_OS_VARIANT` and `BD_OS_VARIANT_ID`: Additional details, where applicable.
`BD_OS_VERSION`: Full OS version string.
`BD_OS_VERSION_ID`: Numeric version (e.g., `20.04`).
`BD_OS_VERSION_MAJOR`: Major version extracted from `BD_OS_VERSION_ID`.

## Use Cases

* Environment-Specific Behavior:
	* Tailor script actions based on the OS type, version, or architecture.
* Debugging and Logging:
	* Use the exported variables to provide OS details in logs or debug outputs.
* Cross-Platform Compatibility:
	* Simplify scripting for systems that need to behave differently on Linux, macOS, or Windows.

## Notable Strengths

* Comprehensive detection logic covering multiple operating systems.
* Modular and reusable design.
* Detailed and precise OS metadata for versatile use.
