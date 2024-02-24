# bash.d

bash directory (bash.d) autoloader

# installing

### what you will probably want to do

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ append
```

### what I do

```
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace
```

### try it

1) clone `bd` into your home directory
    ```sh
    cd && git clone https://github.com/bash-d/bd .bd
    ```

2) paste this or add something like it to the end of your `.bash_profile` and/or `.bashrc`
    ```sh
    [ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
    ```

## supported environment variables

see [.bd.conf](https://github.com/bash-d/bd/blob/main/example/.bd.conf)

## license

[MIT](https://github.com/bash-d/bd/blob/main/LICENSE.md)

# notes

## why?

This started as a project to reduce the size and complexity of single .bash_profile and .bashrc files.  Then `bd` evolved into a build dependency for other projects.  It facilitates the simple use of specific, controlled bits of shell alongside/within other build environments.

For example, create an etc/bash.d within a git repo and put specifics there and then type `bd`.  These are bits most people don't need in their environment _all_ the time, but certainly help in that directory's context.  With little effort, `bd` eventually brought some much needed organization to my personal shell and build environments for other projects.  I use it a lot and thought others might find a use for it too.

I hope continues to evolve and grow into a more useful replacement for the archaic /etc/profile environments that are (still) propagated via most linux distributions today.

