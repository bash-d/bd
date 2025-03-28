# an autoloader for bash

[Documentation](https://github.com/bash-d/bd/tree/main/doc)

### automatic installation

```sh
# main, latest
cd; curl -Ls https://raw.githubusercontent.com/bash-d/bd/main/bd-install.sh | /usr/bin/env bash -s _ replace; . .bash_profile; bd env
```

### manual installation

```sh
# download a release into ~/.bd and add something like this your profile
[ -r ~/.bd/bd.sh ] && source ~/.bd/bd.sh ${@}
```

## example
<img src="example/bd-example.gif?raw=true">

## license

[MIT License](https://github.com/bash-d/bd/blob/main/LICENSE.md)
