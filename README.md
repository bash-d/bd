# Autoloader for Bash

[Documentation](https://github.com/bash-d/bd/tree/main/doc)

### Automatic Installation (backup & replace existing .bash_profile/.bashrc)

```sh
# main, latest
cd; curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | /usr/bin/env bash -s _ replace; . .bash_profile; bd env
```

### Manual Installation

```sh
# download a release into ~/.bd and add something like this your profile
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## License

[MIT License](https://github.com/bash-d/bd/blob/main/LICENSE.md)

## Example
<img src="example/bd-example.gif?raw=true">
