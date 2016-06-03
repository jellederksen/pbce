#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All daemons in the array "${daemons[@]}" will be configured to stop or
#start at boot time depaning on the valua after the comma. This script will
#look for the command line tool "update-rc.d" or "chkconfig" to configure
#the desired state on the host this script is executed on.
#
#Example: turn daemons on or off at boot time.
#daemon[0]='sshd,on'
#daemon[0]='telnetd,off'

jobname='DaemonOnoff'

set_daemon() {
	if [[ -x $(which update-rc.d) ]]; then
		for d in "${daemon[@]}"; do
			#name of init script
			x="$(echo "${d}" | cut -f 1 -d ',')"
			#action enable or disable
			y="$(echo "${d}" | cut -f 1 -d ',' | \
			sed -e 's/on/enable/' -e 's/off/disable/')"
			if [[ ! -f /etc/init.d/${x} ]]; then
				echo "init script ${x} missing" >&2
				exit 1
			fi
			if update-rc.d "${x}" "${y}"; then
				echo "${x} ${y}."
				continue
			else
				echo "Failed to ${x} ${y}." >&2
				exit 2
			fi
		done
	elif [[ -x $(which chkconfig) ]]; then
		for d in "${daemon[@]}"; do
			#name of init script
			x="$(echo "${d}" | cut -f 1 -d ',')"
			#action on or off
			y="$(echo "${d}" | cut -f 2 -d ',')"
			if [[ ! -f /etc/init.d/${x} ]]; then
				echo "init script ${x} missing" >&2
				exit 3
			fi
			if chkconfig "${x}" "${y}"; then
				echo "${x} ${y}."
				continue
			else
				echo "failed to ${x} ${y}." >&2
				exit 4
			fi
		done
	else
		echo 'update-rc.d and chkconfig not available' >&2
		exit 5
	fi
	echo "done changing init start/stop links on $(hostname)"
}

main() {
	check_root
	check_os
	set_daemon
	exit 0
}

main "${@}"

exit 0
