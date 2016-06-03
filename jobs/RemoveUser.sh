#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Try to login to the remote system and execute an echo command

jobname='RemoveUser'

remove_user() {
	/usr/sbin/userdel -r kunyu001
}

main() {
	check_root
	check_os
	remove_user
	exit 0
}

main "${@}"
