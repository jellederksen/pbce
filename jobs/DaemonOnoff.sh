#!/bin/bash
#
#Turn daemon on or off
#
#Version 0.1
#
#Copyright (c) 2016 Jelle Derksen jelle@epsilix.nl
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#
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
