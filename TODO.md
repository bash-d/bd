# TODO ... automate test cases for various version of bash, e.g. ...

# the official bash image (is built with busybox [no git])
```
podman run -it --rm bash:4.4
podman run -it --rm bash:4.4 /usr/local/bin/bash -c 'echo $BASH_VERSION'
podman run -it --rm bash:4.0 /usr/local/bin/bash -c 'echo $BASH_VERSION'
```

# inside ...
```
podman run -it --rm bash:4.0 /usr/local/bin/bash -c 'echo $BASH_VERSION; cd; apk add git; git clone https://github.com/bash-d/bd .bd ; cp .bd/.bash* .; ls -ld .bash*; export BD_DEBUG=10; source .bd/bd.sh; bd env'
```
