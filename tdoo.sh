#!/bin/bash
#
#Turn Daemon(s) On or Off
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#All daemons in the array "$daemons[@]" will be configured to stop or
#start at boot time depaning on the valua after the comma. This script will
#look for the command line tool "update-rc.d" or "chkconfig" to configure
#the desired state on the host this script is executed on. You can execte
#this script on multiple systems using the ssre.sh script.
#
#Example: turn daemons on or off at boot time.
#daemons[0]='sshd,on'
#daemons[0]='telnetd,off'
#
#Example: exclude host from script.
#exclude_hosts[0]='foo.bar.com'
#exclude_hosts[1]='192.168.0.1'

#Script settings change to suit your needs.
daemons[0]=''
exclude_hosts[0]=''

#Do not edit below this point.
#Script checks.
if [[ ! "$USER" = 'root' ]]; then
	echo 'need root privileges'
	exit 1
fi

if [[ ! "$(uname)" = 'Linux' ]]; then
	echo 'OS not Linux.'
	exit 2
fi

if [[ -n "$exclude_hosts" ]]; then
	for x in "${exclude_hosts[@]}"; do
		h="$(echo "$x" | awk -F, '{print $1}')"
		if [[ "$h" = "$(hostname)" ]]; then
			exit 0
		elif [[ "$h" = "$(ip addr show | grep -F -o "$h")" ]]; then
			exit 0
		fi
	done
fi

if [[ -n "$exclude_element_on_host" ]]; then
	for x in "${exclude_element_on_host[@]}"; do
		h="$(echo "$x" | awk -F, '{print $1}')"
		a="$(echo "$x" | awk -F, '{print $2}')"
		e="$(echo "$x" | awk -F, '{print $3}')"
		if [[ -z "$h" || -z "$a" || -z "$e" ]]; then
			echo "$x variable incorrect"
			exit 3
		fi
		if [[ "$(hostname)" = "$h" ]]; then
			unset "${a}[${e}]"
		elif [[ "$h" = "$(ip addr show | grep -F -o "$h")" ]]; then
			unset "${a}[${e}]"
		fi
	done
fi

#Main code.
if [[ -x $(which update-rc.d) ]]; then
	for d in "${daemons[@]}"; do
		#name of init script
		x="$(echo "$d" | awk -F, '{print $1}')"
		#action enable or disable
		y="$(echo "$d" | awk -F, '{print $2}' | \
		sed -e 's/on/enable/' -e 's/off/disable/')"
		if [[ ! -f "/etc/init.d/$x" ]]; then
			echo "Init script $x missing."
			exit 1
		fi
		if update-rc.d "$x" "$y"; then
			echo "${y}d ${x}."
			continue
		else
			echo "Failed to $x ${y}."
			exit 2
		fi
	done
elif [[ -x "$(which chkconfig)" ]]; then
	for d in "${daemons[@]}"; do
		#name of init script
		x="$(echo "$d" | awk -F, '{print $1}')"
		#action on or off
		y="$(echo "$d" | awk -F, '{print $2}')"
		if [[ ! -f /etc/init.d/$x ]]; then
			echo "Init script $x missing."
			exit 1
		fi
		if chkconfig "$x" "$y"; then
			echo "${y}d ${x}."
			continue
		else
			echo "failed to $x $y."
			exit 2
		fi
	done
else
	echo 'Update-rc.d and chkconfig not available.'
	exit 1
fi

echo 'Done changing init start/stop links'
exit 0
