#!/bin/bash
#
#Pbce job for changing sysctl setting
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
		if [[ ${conf} == "${s}" ]]; then
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
		if [[ ${live} = "${s}" ]]; then
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
