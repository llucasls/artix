#!/bin/bash

if test $(id -u) -ne 0; then
	printf "PermissionError: this script must be run as root" >&2
	exit 10
fi

PACKAGES=$(< arch_packages)
FONTS=$(< arch_fonts)

pacman -S ${PACKAGES} ${FONTS}

if test -n $1; then
	USER=$1
elif test -n "${SUDO_USER}"; then
	USER=${SUDO_USER}
elif test -n "${DOAS_USER}"; then
	USER=${DOAS_USER}
else
	printf "Error: username not provided" >&2
	exit 1
fi

HOME=/home/${USER}
REPOS_DIR=${HOME}/.repos

mkdir -p ${REPOS_DIR}

git clone https://github.com/llucasls/dwm.git ${REPOS_DIR}/dwm
make --file=${REPOS_DIR}/dwm/Makefile install clean

git clone https://github.com/llucasls/dmenu.git ${REPOS_DIR}/dmenu
make --file=${REPOS_DIR}/dmenu/Makefile install clean

git clone https://github.com/llucasls/st.git ${REPOS_DIR}/st
make --file=${REPOS_DIR}/st/Makefile install clean

git clone https://github.com/llucasls/tabbed.git ${REPOS_DIR}/tabbed
make --file=${REPOS_DIR}/tabbed/Makefile install clean

chown -R ${USER}:${USER} ${HOME}

if type sudo > /dev/null 2>&1; then
	sudo -u ${USER} ./install_pipx.py
elif type doas > /dev/null 2>&1; then
	doas -u ${USER} ./install_pipx.py
fi
