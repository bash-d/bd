# bash.d

bash directory (bash.d) autoloader

![](example/bd-example.gif | width=100)
<img src="example/bd-example.gif" width="400" height="790">



## installing

### automatically backup & replace ~/.bash_profile and ~/.bashrc (most common)

```
# latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile

# a specific branch, i.e. 0.45.0
curl -Ls https://raw.githubusercontent.com/bash-d/bd/0.45.0/bd-install.sh | BD_INSTALL_BRANCH=0.45.0 bash -s _ replace && source ~/.bash_profile
```

### automatically append to ~/.bash_profile and ~/.bashrc

```
# latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ append # this makes a backup, too

# a specific branch, i.e. 0.45.0
curl -Ls https://raw.githubusercontent.com/bash-d/bd/0.45.0/bd-install.sh | BD_INSTALL_BRANCH=0.45.0 bash -s _ append && source ~/.bash_profile
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

# notes

## why?

`~/etc/bash.d` started as a idea to reduce the size of a .bash_profile and/or .bashrc, like an alternate or personal /etc/profile.d.  I think that concept makes it easier to use specific bits of shell in different environments.  For me, `bd` eventually brought some much needed organization to my personal shell and numerous build environments.
