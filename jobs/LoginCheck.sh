#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Try to login to the remote system and execute an echo command

jobname='LoginCheck'

login_check() {
	/bin/echo "$(hostname) SSH OK"
}

main() {
	check_root
	check_os
	login_check
	exit 0
}

main "${@}"
