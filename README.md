# bash.d

bash directory (bash.d) autoloader

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

### an example
<img src="example/bd-example.gif?raw=true">
