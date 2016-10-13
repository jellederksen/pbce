#!/bin/bash
#
#Pbce jobs for configuring the network in Redhat.
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
#Configure networking on a Redhat 7 Linux-system

#fqdn='hostname.domain.toplevel'
#network_interface[0]='enp0s3,192.84.30.156,24,192.84.30.250'
#network_interface[1]='enp0s8,192.0.2.2,24'
#route[0]='enp0s8,192.0.3.0,24,192.0.2.1'
#route[1]='enp0s8,192.0.4.0,24,192.0.2.1'
#dns_server[0]='enp0s3,8.8.8.8'
#dns_server[1]='enp0s3,8.8.4.4'

shopt -s extglob
jobname='ConfigureNetwork'
conf_dir='/etc/sysconfig/network-scripts'
resolv_conf='/etc/resolv.conf'
net_conf='/etc/sysconfig/network'
n=1

configure_fqdn () {
	if ! hostnamectl set-hostname "${fqdn%%.*}"; then
		echo "failed to set hostname"
		exit 99
	fi
	echo "NOZEROCONF='yes'" > "${net_conf}"
	echo "NETWORKING='yes'" >> "${net_conf}"
	#We configure the fqdn when we configure
	#the interface with the default gateway.
}

cleanup_conf() {
	rm "${conf_dir}"/ifcfg-!(lo) "${conf_dir}"/route-!(lo) > /dev/null 2>&1
}

configure_network() {
	#Set and configure network interfaces
	for i in "${network_interface[@]}"; do
		while IFS=',' read -r nif ip cidr gw; do
			if [[ $gw ]]; then
				echo "DEVICE='${nif}'" > "${conf_dir}/ifcfg-${nif}"
				echo "BOOTPROTO='none'" >> "${conf_dir}/ifcfg-${nif}"
				echo "ONBOOT='yes'" >> "${conf_dir}/ifcfg-${nif}"
				echo "PREFIX='${cidr}'" >> "${conf_dir}/ifcfg-${nif}"
				echo "IPADDR='${ip}'" >> "${conf_dir}/ifcfg-${nif}"
				echo "GATEWAY='${gw}'" >> "${conf_dir}/ifcfg-${nif}"
				echo "DOMAIN='${fqdn#*.}'" >> "${conf_dir}/ifcfg-${nif}"
			else
				echo "DEVICE='${nif}'" > "${conf_dir}/ifcfg-${nif}"
				echo "BOOTPROTO='none'" >> "${conf_dir}/ifcfg-${nif}"
				echo "ONBOOT='yes'" >> "${conf_dir}/ifcfg-${nif}"
				echo "PREFIX='${cidr}'" >> "${conf_dir}/ifcfg-${nif}"
				echo "IPADDR='${ip}'" >> "${conf_dir}/ifcfg-${nif}"
			fi
		done <<< "${i}"
	done
	#Set and configure routes
	for i in "${route[@]}"; do
		while IFS=',' read -r nif ip cidr gw; do
			echo "${ip}/${cidr} via ${gw}" >> "${conf_dir}/route-${nif}"
		done <<< "${i}"
	done
	#Set and configure the DNS servers
	for i in "${dns_server[@]}"; do
		while IFS=',' read -r nif dns_server; do
			echo "DNS$((n++))='${dns_server}'" >> "${conf_dir}/ifcfg-${nif}"
		done <<< "${i}"
	done
}

restart_network() {
	if ! systemctl restart network > /dev/null 2>&1; then
		echo "failed to restart network"
		exit 99
	fi
}

main() {
	check_root
	check_os
	cleanup_conf
	configure_fqdn
	configure_network
	restart_network
	exit 0
}

main "${@}"
