#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Execute command script

jobname='ExecuteCommand'

execute_command() {
	echo 'pbce: ExecuteCommand job'
}

main() {
	check_root
	check_os
	execute_command
	exit 0
}

main "${@}"
