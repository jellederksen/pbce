#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelle@jellederksen.nl
#Website www.jellederksen.nl
#
#Change sysctl setting on the host this script is executed on. Please add
#all sysctl settings you want to change to the "${sysctl_setting[@]}" array.
#
#Example: change or add sysctl settings.
#sysctl_setting[0]='net.ipv4.conf.all.forwarding = 0'
#sysctl_setting[1]='net.ipv4.conf.all.forwarding = 1'

jobname='ChangeSysctl'

change_sysctl() {
	for s in "${sysctl_setting[@]}"; do
		conf="$(< "${sysctl_conf}" grep "${s%% = [0-1]}")"
		if [[ ${conf} == ${s} ]]; then
			echo "sysctl setting ${s} correct in ${sysctl_conf}"
		elif [[ -z ${conf} ]]; then
			echo "${s}" >> "${sysctl_conf}"
		else
			if ! sed -i "s/${conf}/${s}/" "${sysctl_conf}"; then
				echo "failed to change ${sysctl_conf}" >&2
				exit 1
			else
				echo "${sysctl_conf} changed"
			fi
		fi
		live="$(sysctl "${s%% = [0-1]}")"
		if [[ ${live} = ${s} ]]; then
			echo "sysctl setting ${s} correct state active"
		else
			s="$(echo "${s}" | sed 's/ //g')"
			if sysctl "${s}"; then
				echo "activated ${s}"
			else
				echo "failed to activate ${s}" >&2
				exit 2
			fi
		fi
	done
	echo "All sysctl settings have the correct value on $(hostname)"
}

main() {
	check_root
	check_os
	change_sysctl
	exit 0
}

main "${@}"
