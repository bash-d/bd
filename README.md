# bash.d

bash directory (bash.d) autoloader

## installing

### automatically replace ~/.bash_profile and ~/.bashrc (what I do)

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace # this makes a backup, too
```

### automatically append to ~/.bash_profile and ~/.bashrc

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ append # this makes a backup, too
```

### manual

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
