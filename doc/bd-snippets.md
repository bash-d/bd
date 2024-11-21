# `bd-snippet.sh`: Easily Incorporate Additional Bits of Bash

The `bd-snippet.sh` script is a utility module for managing "snippets" in the `bash-d` ecosystem.

_Please note that this is currently (0.45.0) a rough outline and work in progress._

## Purpose

This script is a tool for managing reusable Bash bits in the `bash-d` system, enhancing productivity and ensuring consistency across environments. It provides a suite of commands to `fetch`, `list`, `hash`, and `remove` Bash script snippets. It is designed to streamline the management of reusable code stored in a centralized directory.

## Integration with `bd.sh`

* Complements the `bash-d` ecosystem by providing a mechanism to manage reusable code snippets that can be autoloaded or manually sourced.
* Relies on `BD_SNIPPET_DIR`, which is initialized in the broader `bash-d` system.

## Key Features

### Initialization and Safety Checks:

* Prevents direct execution, requiring the script to be sourced (`source bd-snippet.sh`).
* Ensures the `BD_SNIPPET_DIR` is properly set up as a directory; creates it if it doesn't exist.

### Main Functionality (`_bd_snippet`):

* Serves as a dispatcher for snippet-related subcommands:
	* `get`: Download and optionally source a snippet.
	* `hash`: Display MD5 hashes of all snippets.
	* `list` or `ls`: List all snippets with details.
	* `remove` or `rm`: Delete a specified snippet.
* Checks for required utilities (`curl`, `ls`, `rm`) before executing any operation.

### Subcommand Details:

* `_bd_snippet_get`:
	* Downloads a snippet from a specified URL.
	* Supports renaming the downloaded snippet based on its filename.
	* Prompts the user for confirmation before replacing an existing snippet.
	* Offers the option to source the snippet immediately after downloading.
* `_bd_snippet_hash`:
	* Computes and displays MD5 hashes for all snippets in the `BD_SNIPPET_DIR`.
* `_bd_snippet_list`:
	* Lists all snippets in the BD_SNIPPET_DIR with their file details.
* `_bd_snippet_remove`:
	* Removes a specified snippet with interactive confirmation.
	* Handles file permissions gracefully, reporting errors for unreadable or unwritable files.

### User Interaction:

* Prompts users for decisions (e.g., whether to replace or source a snippet) to ensure safety and control.
* Provides clear error messages for invalid operations or missing prerequisites.

### Dynamic File Management:

* Automatically determines and validates file paths for snippet storage.
* Uses safe operations (e.g., interactive removal) to prevent accidental data loss.

## Use Cases

* **Developers**: Quickly fetch and reuse common scripts or functions without manual copying.
* **System Administrators**: Maintain a library of reusable scripts for automation and configuration.
* **Power Users**: Simplify the management of custom Bash extensions or utilities.

## Environment Variables Used

`BD_SNIPPET_DIR`: Central directory for storing snippets.
`BD_YN`: Used for user confirmation prompts.

## Notable Strengths

* Comprehensive management of snippet lifecycle: `download`, `verify`, `use`, and `remove`.
* User-friendly prompts and error messages enhance reliability and usability.
* Flexible filename handling ensures compatibility with various URL formats and extensions.
