# An Advanced Directory Autoloader for Bash

### Automatic Installation (backup & replace existing .bash_profile/.bashrc)

```sh
# main, latest
curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | bash -s _ replace && source ~/.bash_profile
```

### Manual Installation

```sh
# download a release into ~/.bd and add something like this your profile
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## License

[MIT License](https://github.com/bash-d/bd/blob/main/LICENSE.md)

### An Example
<img src="example/bd-example.gif?raw=true">
