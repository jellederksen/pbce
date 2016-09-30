#!/bin/bash
#
#Pbce job for adding users to a Linux system
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
#All users in the array "$user[@]" will be added to the host this
#script is executed on. The correct syntax for the "$user[@]"
#variable can be seen in the example. Please mind the quotes arround
#the full_name part. You will need the quotes when using a space
#between the first and last name.
#
#Example: add user accounts.
#user[0]="group_name,'full_name',home_directory,prefered_shell,account_name"
#user[1]="jelle,'Jelle Derksen',/home/jelle,/bin/ksh,jelle"

jobname='AddUser'
me="$jobname"

add_user() {
	for u in "${user[@]}"; do
		g="$(echo "${u}" | cut -f 1 -d ',')"
		n="$(echo "${u}" | cut -f 2 -d ',')"
		#Remove quotes around the user's full name
		eval n="${n}"
		h="$(echo "${u}" | cut -f 3 -d ',')"
		s="$(echo "${u}" | cut -f 4 -d ',')"
		a="$(echo "${u}" | cut -f 5 -d ',')"
		if [[ -z ${g} || -z ${n} || -z ${h} || -z ${s} || -z ${a} ]]; then
			echo "${me}: ${u} variable incorrect" >&2
			exit 1
		fi
		if id "${a}" > /dev/null 2>&1; then
			echo "${me}: ${a} already on $(hostname)"
			continue
		fi
		if ! getent group "${g}" > /dev/null 2>&1; then
			echo "${me}: ${g} group does not exist adding group"
			if ! groupadd "${g}" > /dev/null 2>&1; then
				echo "${me}: failed to add group ${g}" >&2
				exit 2
			fi
		fi
		if useradd -g "${g}" -c "${n}" -d "${h}" -s "${s}" "${a}"; then
			echo "${me}: ${a} added on host $(hostname)"
		else
			echo "${me}: failed to add ${a} on host $(hostname)" >&2
			exit 3
		fi
	done
	echo "${me}: all accounts added on host $(hostname)"
}

main() {
	check_root
	check_os
	add_user
	exit 0
}

main "${@}"
