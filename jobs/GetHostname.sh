#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Display the configured hostname on the system this script is
#executed on.

jobname='GetHostname'
jobgroup=''
jobdepends=''

get_hostname() {
	if echo "Hostname: $(/bin/hostname)"; then
		return 0
	else
		echo "Failed to get hostname"
		exit 1 
	fi
}

main() {
	check_root
	check_os
	get_hostname
	exit 0
}

main "$@"
