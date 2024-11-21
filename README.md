# An Advanced Directory Autoloader for Bash

This repository is dedicated to implementing a smarter, more adaptable solution for Bash environment management.

## The Solution: `bash-d`

Here we provide a solution that seamlessly integrates with your existing Bash setup to provide:

* Flexible Sourcing: Automatically load scripts from both system-wide and user/project-specific directories.
* Seamless Integration: Works seamlessly with standard Bash startup processes, including `/etc/profile` and `/etc/bashrc`.
* Enhanced Customization: Tailor your Bash environment to your specific needs without modifying core system files.
* Save Time: Automate repetitive tasks and streamline your workflow.
* Boost Productivity: Access your favorite tools and aliases instantly.
* Maintain Consistency: Ensure a consistent Bash environment across different projects.
* Simplify Management: Easily manage and organize your Bash configuration.

It allows automatically sourcing scripts from strategic locations:

* User-specific: `${HOME}/etc/bash.d`
* Project-specific: `${PWD}/etc/bash.d`
* System-wide: `/etc/bash.d`

## Installing

### Automatically backup & replace `~/.bash_profile` and `~/.bashrc`

```
# main, latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile
```

```
# a specific branch, i.e. 0.45.0
curl -Ls https://raw.githubusercontent.com/bash-d/bd/0.45.0/bd-install.sh | BD_INSTALL_BRANCH=0.45.0 bash -s _ replace && source ~/.bash_profile
```

### Automatically append to `~/.bash_profile` and `~/.bashrc`

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ append # this makes a backup, too
```

### Manual Installation

1) clone `bd` into your home directory
```sh
cd && git clone https://github.com/bash-d/bd .bd
```

2) paste this or add something like it to the end of your `.bash_profile` and/or `.bashrc`
```sh
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## License

[MIT License](https://github.com/bash-d/bd/blob/main/LICENSE.md)

## Notes

### Objectives:

* Pure Bash (as much as possible)
* No duplicate executions
* No recursion loops; definite, predictable order of execution
* Don't break /etc/profile.d, override if needed
* Don't rely on /etc or root access
* Work with /etc/profile.d, /etc/bash.d, ~/etc/bash.d, and $PWD/etc/bash.d

### An Example
<img src="example/bd-example.gif?raw=true">
