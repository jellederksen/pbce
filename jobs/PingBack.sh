#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Login to the remote system and try to ping back the server in the
#pingaddr variable. This script is used to test pbce and network
#connectivity.

jobname='PingBack'
jobgroup=''
jobdepends=''
pingaddr="145.222.59.32"

pingback() {
	if /bin/ping -c 2 "$pingaddr"; then
		echo "PingBack ok"
		return 0
	else
		echo "PingBack failed"
		return 0
	fi
}

main() {
	check_root
	check_os
	pingback
	exit 0
}

main "$@"
