# An Advanced Directory Autoloader for Bash

### Automatic Installation (backup & replace existing .bash_profile/.bashrc)

```
# main, latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile
```

### Manual Installation

* Download a release, or clone the repo, and add something like it to the end of your profile ...
```sh
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## License

[MIT License](https://github.com/bash-d/bd/blob/main/LICENSE.md)

### An Example
<img src="example/bd-example.gif?raw=true">
