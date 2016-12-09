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
#Configure ntp daemon on a Redhat 7 Linux-system for KPN template

jobname='ConfigureNtp'

ntp_conf='/etc/ntp.conf'
dn='/dev/null'

restart_ntpd() {
	if [[ $(cut -d ' ' -f 7 /etc/redhat-release) =~ 6\..* ]]; then
		if service ntpd restart > "${dn}" 2>&1; then
			return 0
		else
			return 1
		fi
	elif [[ $(cut -d ' ' -f 7 /etc/redhat-release) =~ 7\..* ]]; then
		if systemctl restart ntpd > "${dn}" 2>&1; then
			return 0
		else
			return 1
		fi
	else
		echo "unknown redhat version"
		exit 1
	fi
}

configure_ntp() {
	if ! cp "$ntp_conf" "$ntp_conf.$(date +%s).bak"; then
		echo "failed to backup ntp config on $(hostanme -s)"
		exit 2
	fi

	if grep 'server 145.222.16.132' "$ntp_conf" > "$dn"; then
		if ! sed -i '/server 145.222.16.132/{s//server 172.16.88.4/;h};${x;/./{x;q0};x;q1}' "$ntp_conf"; then
			echo "failed to change ntp server on $(hostname -s)"
			exit 3
		else
			if ! restart_ntpd; then
				echo "failed to restart ntpd on $(hostname -s)"
				exit 4
			fi
		fi
	fi

	if grep 'server 145.222.16.148' "$ntp_conf" > "$dn"; then
		if ! sed -i '/server 145.222.16.148/{s//server 172.16.88.20/;h};${x;/./{x;q0};x;q1}' "$ntp_conf"; then
			echo "failed to change ntp server on $(hostname -s)"
			exit 5
		else
			if ! restart_ntpd; then
				echo "failed to restart ntpd on $(hostname -s)"
				exit 6
			fi
		fi
	fi

	ntp_servers=( $(grep '^server' "$ntp_conf" | cut -d  ' ' -f 2 | grep -v '127\.127\.1\.0') )

	for i in "${ntp_servers[@]}"; do
		if [[ ! $i  =~ 172\.16\.88\..* ]]; then
			echo "unknown ntp-server in $ntp_conf on $(hostname -s)"
			exit 7
		fi
	done
}

main() {
	check_root
	check_os
	configure_ntp
	exit 0
}

main "${@}"
