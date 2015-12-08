#!/bin/bash
#
#Change Sysctl On Host
#
#Change sysctl setting on the host this script is executed on. You can execute
#this script on multiple hosts with the use of the ssre.sh script. Please add
#all sysctl settings you want to change to the "${sysctl_setting[@]}" array.
#
#Copyright 2016 Jelle Derksen
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl

sysctl_conf='/etc/sysctl.conf'

sysctl_setting[0]='net.ipv4.conf.all.forwarding = 0'
sysctl_setting[1]='net.ipv4.conf.all.forwarding = 1'

if [[ ! "$USER" = root ]]; then
	echo 'need root privileges'
	exit 1
fi

if [ ! -f "$sysctl_conf" ]; then
        echo "sysctl $sysctl_conf missing"
        exit 2
fi

for s in "${sysctl_setting[@]}"; do
	conf="$(< "$sysctl_conf" grep "${s%% = [0-1]}")"
	if [[ $conf = $s ]]; then
		echo "sysctl setting $s correct in $sysctl_conf"
	elif [[ -z $conf ]]; then
		echo "$s" >> "$sysctl_conf"
	else
		if ! sed -i "s/$conf/$s/" "$sysctl_conf"; then
			echo "failed to change $sysctl_conf"
			exit 3
		else
			echo "$sysctl_conf changed"
		fi
	fi
	live="$(sysctl "${s%% = [0-1]}")"
	if [[ $live = $s ]]; then
		echo "sysctl setting $s correct state active"
	else
		s="$(echo "$s" | sed 's/ //g')"
		if sysctl "$s"; then
			echo "activated $s"
		else
			echo "failed to activate $s"
			exit 4
		fi
	fi
done

exit 0
