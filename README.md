# bash autoloader

This repository is dedicated to implementing a smarter, more adaptable solution for Bash profile management.

Most Linux distributions build upon Bash's default startup behavior and utilize `/etc/profile.d` as a system-wide mechanism to autoload Bash environment profiles. In practice, this concept has significant value.

In typical modern distros, the /etc/profile file contains a conditional logic chain that sources `/etc/bashrc`, which in turn includes all scripts from `/etc/profile.d`. Usually, these are the final lines of execution in both files.

Here we provide a solution that allows automatically sourcing a set of scripts after `/etc/bashrc` and everything in `/etc/profile.d`. Furthermore, this mechanism is flexible enough to autoload scripts from both `$HOME/etc/bash.d` and `${PWD}/etc/bash.d`.

## installing

### automatically backup & replace ~/.bash_profile and ~/.bashrc

```
# main, latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile
```

```
# a specific branch, i.e. 0.45.0
curl -Ls https://raw.githubusercontent.com/bash-d/bd/0.45.0/bd-install.sh | BD_INSTALL_BRANCH=0.45.0 bash -s _ replace && source ~/.bash_profile
```

### automatically append to ~/.bash_profile and ~/.bashrc

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ append # this makes a backup, too
```

### manual installation

1) clone `bd` into your home directory
```sh
cd && git clone https://github.com/bash-d/bd .bd
```

2) paste this or add something like it to the end of your `.bash_profile` and/or `.bashrc`
```sh
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## license

[MIT](https://github.com/bash-d/bd/blob/main/LICENSE.md)

## notes

### objectives:

* Pure Bash (as much as possible)
* No duplicate executions
* No recursion loops; definite, predictable order of execution
* Don't break /etc/profile.d, override if needed
* Don't rely on /etc or root access
* Work with /etc/profile.d, /etc/bash.d, ~/etc/bash.d, and $PWD/etc/bash.d

### an example
<img src="example/bd-example.gif?raw=true">
