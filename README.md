# Misc tools for Alpine


## Setup docker container


! You must to create a local folder `ssh_keys/` with yours ssh keys to authorize
your git cloning and setup of your `abuild-keygen`.

The default parameters will raise a container with user devel without email and
get the source from git://git.alpinelinux.org/aports, but you can customize your
user as showed below:
```
docker build  -t alpine:dev -f Dockerfile-AlpineDev . --build-arg USER=walbon \
--build-arg USERNAME="Gustavo Walbon" --build-arg USERMAIL="gustavowalbon@gmail.com" \
--build-arg GIT_URL=git@gitlab.alpinelinux.org:walbon/aports.git
```

!!! ToDo
 - The EDGE parameter got an error if you use a folder which doesn't have all
   default sub-folders, eg. v3.11 is missing the community for ppc64le.

