#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Configure networking on a Redhat 7 Linux-system

jobname='ConfigureNetwork'
conf_dir='/etc/sysconfig/network-scripts'
resolv_conf='/etc/resolv.conf'
net_conf='/etc/sysconfig/network'

#fqdn='hostname.domain.toplevel'
#network_interface[0]='if_name,if_addr,cidr'
#default_route='1.2.3.4'
#additional_route[0]='192.168.0.0,24,172.16.0.1'
#additional_route[0]='145.222.132.0,24,10.117.144.65'
#additional_route[1]='145.222.58.0,24,10.117.144.65'
#additional_route[2]='145.222.59.0,24,10.117.144.65'
#additional_route[3]='145.222.97.0,24,10.117.144.65'
#additional_route[4]='145.222.98.0,24,10.117.144.65'
#additional_route[5]='10.231.11.0,24,10.117.144.65'
#additional_route[6]='145.222.16.132,32,10.117.144.65'
#additional_route[7]='145.222.16.148,32,10.117.144.65'
#dns_server[0]='1.2.3.4'
#dns_server[1]='4.3.2.1'

configure_fqdn () {
	if ! hostnamectl set-hostname "${fqdn%%.*}"; then
		echo "failed to set hostname"
		exit 99
	fi
	echo "NOZEROCONF='yes'" > "${net_conf}"
	echo "NETWORKING='yes'" >> "${net_conf}"
	echo "DOMAINNAME='${fqdn#*.}'" >> "${net_conf}"
}

configure_network() {
	#Set and configure network interfaces
	for i in "${network_interface[@]}"; do
		while IFS=',' read -r if ip cidr; do
			if ! ifconfig "$if" "${ip}/${cidr}" > /dev/null 2>&1;; then
				echo "failed to configure interface ${if}"
				exit 2
			fi
			echo "DEVICE='${if}'" > "${conf_dir}/ifcfg-${if}"
			echo "BOOTPROTO='none'" >> "${conf_dir}/ifcfg-${if}"
			echo "ONBOOT='yes'" >> "${conf_dir}/ifcfg-${if}"
			echo "PREFIX='${cidr}'" >> "${conf_dir}/ifcfg-${if}"
			echo "IPADDR='${ip}'" >> "${conf_dir}/ifcfg-${if}"
		done <<< "${i}"
	done
	#Set and configure additional routes
	for i in "${additional_route[@]}"; do
		while IFS=',' read -r net cidr gw; do
		if ! ip route add "${net}/${cidr}" via "${gw}"
			echo "failed to add route"
			exit 3
		fi
		gw_if="$(ip -o route get "${gw}" | cut -f 5 -d' ')"
		echo "${net}/${cidr} via {$gw}" >> "${conf_dir}/route-${gw_if}"
	done <<< "${i}"
	#Set and configure the default gateway
	df_gw_if="$(ip -o route get "$default_route" | cut -f 3 -d' ')"
	if ! ip route add default via "$default_route"; then
		echo "failed to add default route"
		exit 4
	fi
	echo "GATEWAY='$default_route'" >> "${conf_dir}/ifcfg-${df_gw_if}"
	#Set and configure the DNS servers
	i='1'
	for i in "${dns_server[@]}"; do
		dns_if="$(ip -o route get "${i}" | cut -f 5 -d' ')"
		echo "DNS$((n++))='${i}'" >> "${conf_dir}/ifcfg-${dns_if}"
		echo "nameserver ${i}" >> "${resolv_conf}"
	done
}

main() {
	check_root
	check_os
	configure_fqdn
	configure_network
	exit 0
}

main "${@}"
