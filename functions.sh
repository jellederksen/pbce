#!/bin/bash
#
#Functions for pbce scripts
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl

check_root() {
	if [[ ! "$USER" = 'root' ]]; then
		echo 'need root privileges'
		exit 1
	fi
}

check_os() {
	if [[ ! "$(uname)" = 'Linux' ]]; then
		echo 'OS not Linux.'
		exit 2
	fi
}
