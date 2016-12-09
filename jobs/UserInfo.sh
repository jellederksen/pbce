#!/bin/bash
#
#Display user information
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
jobname='UserInfo'
passwd_file='/etc/passwd'
shadow_file='/etc/shadow'

find_users() {
	users=( $(awk -F: '{print $1","$3","$6}' /etc/passwd))
	if [[ -z $users ]]; then
		echo 'no users found in passwd'
		exit 99
	fi
}

check_sshkey () {
	if [[ -s ${1}/.ssh/authorized_keys ]]; then
		echo -n 'yes,'
	else
		echo -n 'no,'
	fi
}

check_password () {
	while IFS=':' read a passwd_shasum b; do
		if [[ $passwd_shasum == !! ]]; then
			echo -n 'no,'
		else
			echo -n 'yes,'
		fi
	done <<< "$(grep "${1}:" /etc/shadow)"
}

list_secgroups () {
	id -Gn "${1}" | tr '\n' ','
}

check_sudo () {
	sudo_list="$(sudo -l -U "${1}" | \
	grep 'NOPASSWD:' | \
	sed 's/.*NOPASSWD: //' | \
	sed 's/,/ /g' | sed 's/  */ /g' | tr -d '\n')"
	if [[ $sudo_list ]]; then
		echo -n "${sudo_list},"
	else
		echo -n 'none,'
	fi
}

last_login () {
	last_login="$(lastlog -u "${1}" | \
	grep -v "Username" | \
	sed 's/  */ /g' | \
	awk '{print $4, $5, $6, $7}')"
	if [[ $last_login =~ in\*\* ]]; then
		echo "never"
	elif [[ $last_login ]]; then
		echo "$last_login"
	else
		echo 'unknown'
	fi
}

report_users() {
	echo "hostname,ruisnaam,ssh keys access,password access,user part of groups,allowed sudo commands,last login"
	for i in "${users[@]}"; do
		while IFS=',' read username uid homedir; do
			[[ $uid -ge 500 && ${username} =~ ^[a-z]{5}[0-9]{3}$ ]] || continue
				echo -n "$(hostname -s),"
				echo -n "${username},"
				check_sshkey "${homedir}"
				check_password "${username}"
				list_secgroups "${username}"
				check_sudo "${username}"
				last_login "${username}"
		done<<< "$i"
	done
}

main() {
	check_root
	check_os
	find_users
	report_users
	exit 0
}

main "${@}"
