# An Advanced Directory Autoloader for Bash

### Automatic Installation (backup & replace existing .bash_profile/.bashrc)

```
# main, latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile
```

### Manual Installation

* Download a release, or clone the repo, and add something like it to the end of your `.bash_profile` and/or `.bashrc` ...
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
