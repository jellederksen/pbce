#!/bin/bash
#
#Poor bastard command executer.
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
#Poor Bastard Command Executer execute jobs and commands on remote Linux systems.

#Script variables
pbce_dir='/home/jelled/github/pbce/bin'
fqdn_regex='^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$'
ip_regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'
me="${0##*/}"

#Script functions
usage() {
	echo "usage: ${me} [-h] [Hostname_or_GroupName] [-j] [JobName]" >&2
	exit 1
}

get_pars() {
	if [[ -z ${1} ]]; then
		usage
		exit 2
	else
		while getopts Hh:j:c:C n
		do
			case "${n}" in
			H)
				help
				exit 3
				;;
			h)
				host="${OPTARG}"
				;;
			j)
				job="${OPTARG}"
				;;
			c)
				cmd="${OPTARG}"
				;;
			C)
				#create config file for host
				config_menu='yes'
				;;
			*)
				help
				exit 4
			esac
		done
	fi
}

check_host() {
	if [[ ${1} =~ ${fqdn_regex} || ${1} =~ ${ip_regex} ]]; then
		true
	else
		echo "${me}: ${1} not a valid fqdn or IP address" >&2
		exit 5
	fi
}

get_hosts() {
	if [[ ${host} = all ]]; then
		hosts=( $(grep -H -F 'hostname=' "${pbce_dir}"/hosts/*.conf | \
		cut -d':' -f 1) )
	else
		hosts=( $(grep -H -F "groupname='${host}'" \
		"${pbce_dir}"/hosts/*.conf | cut -d':' -f 1) )
		if [[ -z ${hosts} ]]; then
			hosts=( $(grep -H -F "hostname='${host}'" \
			"${pbce_dir}"/hosts/*.conf | cut -d':' -f 1) )
		fi
	fi
	if [[ -z ${hosts} ]]; then
		echo "${me}: no hosts found" >&2
		exit 6
	else
		for h in "${hosts[@]}"; do
			h="$(grep -F 'hostname=' "$h" | cut -d"'" -f 2)"
			check_host "${h}"
		done
	fi
}

check_job() {
	job_type="$(file "${1}" | cut -d' ' -f 2)"
	if [[ ${job_type} != Bourne-Again ]]; then
		echo "${me}: ${1} not a Bourne-Again shell script" >&2
		exit 7
	fi
}

get_job() {
	job_name="$(grep -H -F "jobname='${job}'" \
	"${pbce_dir}"/jobs/*.sh | cut -d':' -f 1)"
	if [[ -z ${job_name} ]]; then
		echo "${me}: no job found" >&2
		exit 8
	else
		check_job "${job_name}"
	fi
}

make_script() {
	config64="$(base64 -w0 "${1}")"
	functions64="$(base64 -w0 "${pbce_dir}/functions/functions.sh")"
	job64="$(base64 -w0 "${job_name}")"
	if [[ -z ${config64} || -z ${functions64} || -z ${job64} ]]; then
		echo "${me}: failed to compile script" >&2
		exit 9
	else
		final_script="${config64}${functions64}${job64}"
	fi
}

make_cmd() {
	config64="$(base64 -w0 "${1}")"
	functions64="$(base64 -w0 "${pbce_dir}/functions/functions.sh")"
	cmd64="$(echo "${cmd}" | base64 -w0)"
	if [[ -z ${cmd64} || -z ${functions64} || -z ${cmd64} ]]; then
		echo "${me}: failed to compile script" >&2
		exit 9
	else
		final_script="${config64}${functions64}${cmd64}"
	fi
}

get_vars() {
	sshuser="$(grep -F 'sshuser=' "${1}" | cut -d"'" -f 2)"
	hostname="$(grep -F 'hostname=' "${1}" | cut -d"'" -f 2)"
	if [[ -z ${sshuser} || -z ${hostname} ]]; then
		echo "${me}: failed get hostname or sshuser from ${1}" >&2
		exit 10
	fi
}

execute_job() {
	for h in "${hosts[@]}"; do
		make_script "${h}"
		get_vars "${h}"
		echo "${me}: Working on ${hostname}" >&2
		ssh -q -o StrictHostKeyChecking=no "${sshuser}@${hostname}" \
		echo "${final_script} | base64 -d | sudo bash"
		if [[ ! ${?} -eq 0 ]]; then
			#echo "${me}: error on host ${hostname}" >&2
			echo "${me}: unable to login to host ${hostname}" >&2
			#exit 11
		fi
	done
}

execute_cmd() {
	for h in "${hosts[@]}"; do
		make_cmd "${h}"
		get_vars "${h}"
		echo "${me}: Working on ${hostname}" >&2
		ssh -q -o StrictHostKeyChecking=no "${sshuser}@${hostname}" \
		echo "${final_script} | base64 -d | sudo bash"
		if [[ ! ${?} -eq 0 ]]; then
			echo "${me}: error on host ${hostname}" >&2
			exit 11
		fi
	done
}

#pbce host config file functions

add_ssh_key() {
	for i in "${hosts[@]}"; do
		source "${i}"
		#Put all index numbers of user_pubkey array
		#in next_index array.
		next_index=(${!user_pubkey[@]})
		#Get highest number from next_index array
		#and put it in next_index variable.
		next_index=${next_index[@]: -1}
		#Increment next_index number by 1 so we can
		#use it to any a new element to the array in
		#the config file hostname.conf
		((next_index++))
		echo "user_pubkey[$next_index]=\"${username},'$ssh_pubkey'\"" >> "${i}"
		#unset the user_pubkey array for the next iteration
		unset user_pubkey
	done
}

add_user() {
	for i in "${hosts[@]}"; do
		source "${i}"
		#Put all index numbers of user array
		#in next_index array.
		next_index=(${!user[@]})
		#Get highest number from next_index array
		#and put it in next_index variable.
		next_index=${next_index[@]: -1}
		#Increment next_index number by 1 so we can
		#use it to any a new element to the array in
		#the config file hostname.conf
		((next_index++))
		echo "user[$next_index]=\"${username},'${fullname}',$homedir,$shell,$username\"" >> "${i}"
		#unset the user array for the next iteration
		unset user
	done
}

menu_manage_users() {
	PS3='Please enter your choice: '
	options=( 'add user' 'remove user' 'exit' )
	select opt in "${options[@]}"; do
		case "$opt" in
		'add user')
			echo -n "enter username: "
			read username
			echo -n "enter fullname: "
			read fullname
			[[ $fullname ]] || fullname="${username}"
			echo -n "enter homedir: "
			read homedir
			[[ $homedir ]] || homedir="/home/${username}"
			echo -n "enter shell: "
			read shell
			[[ $shell ]] || shell='/bin/bash'
			echo -n "enter hostname: "
			read host
			get_hosts
			add_user
			exit 0
		;;
		'remove user')
			echo -n "enter username: "
			read username
		;;
		exit)
			exit 99
		;;
		esac
	done
}

menu_manage_sshkeys() {
	PS3='Please enter your choice: '
	options=( 'add ssh key' 'remove ssh key' 'exit' )
	select opt in "${options[@]}"; do
		case "$opt" in
		'add ssh key')
			echo -n "enter username: "
			read username
			echo -n "enter ssh public key: "
			read ssh_pubkey
			echo -n "enter hostname: "
			read host
			get_hosts
			add_ssh_key
			exit 0
		;;
		'remove ssh key')
			echo -n "enter host or group name: "
			read i
			echo -n "enter username: "
			read u
		;;
		exit)
			exit 99
		;;
		esac
	done
}

menu_manage_host() {
	PS3='Please enter your choice: '
	options=( 'create host' 'remove host' 'disable host' 'enable host' 'exit' )
	select opt in "${options[@]}"; do
		case "$opt" in
		'create host')
			echo 'create host'
			exit 0
		;;
		'remove host')
			echo 'remove host'
			exit 0
		;;
		'disable host')
			echo 'disable host'
			exit 0
		;;
		'enable host')
			echo 'enable host'
			exit 0
		;;
		'exit')
			exit 99
		;;
		esac
	done
}

main_config_menu () {
	PS3='Please enter your choice: '
	options=( 'manage host' 'manage users' 'manage ssh keys' 'exit' )
	select opt in "${options[@]}"; do
		case "$opt" in
		'manage host')
			menu_manage_host
		;;
		'manage users')
			menu_manage_users
		;;
		'manage ssh keys')
			menu_manage_sshkeys
		;;
		'exit')
			exit 99
		;;
		*)
			echo 'Invalid option'
		;;
		esac
	done
}

#Main script.
main() {
	get_pars "${@}"
	if [[ $config_menu ]]; then
		main_config_menu
	fi
	get_hosts
	if [[ $cmd ]]; then
		execute_cmd
	else
		get_job
		execute_job
	fi
	exit 0
}

main "${@}"
