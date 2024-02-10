#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)
SAMBA_V_OUTPUT=$(docker run --rm -ti ubuntu:22.04 /bin/bash -c "apt -qq update 2> /dev/null && apt show samba 2> /dev/null")
export SAMBA_VERSION=$(echo "$SAMBA_V_OUTPUT" | grep "Version: " | grep "[0-9]:[0-9\.]\+" -o | sed "s/[0-9]://g")
export UBUNTU_VERSION=$(docker run --rm -ti "$IMG" cat /etc/os-release  | grep VERSION_CODENAME | cut -d= -f2- | tr -d '\r')
[ -z "$UBUNTU_VERSION" ] && exit 1

export IMGTAG=$(echo "$1a$UBUNTU_VERSION-s$SAMBA_VERSION")
export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi