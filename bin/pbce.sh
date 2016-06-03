#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelle@jellederksen.nl
#Website www.jellederksen.nl
#
#Poor Basterds Command Executer execute commands on remote Linux systems.

#Script variables
pbce_dir='/home/l-fallback/jelle/pbce'
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
		while getopts Hh:j: n
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
	config64="$(base64 -w0 ${1})"
	functions64="$(base64 -w0 "${pbce_dir}/functions/functions.sh")"
	job64="$(base64 -w0 "${job_name}")"
	if [[ -z ${config64} || -z ${functions64} || -z ${job_name} ]]; then
		echo "${me}: failed to compile script" >&2
		exit 9
	else
		final_script="${config64}${functions64}${job64}"
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
		echo "${me}: Working on ${hostname}"
		ssh -q -o StrictHostKeyChecking=no "${sshuser}@${hostname}" \
		echo "${final_script} | base64 -d | sudo bash"
		if [[ ! ${?} -eq 0 ]]; then
			echo "${me}: error on host ${hostname}" >&2
			exit 11
		fi
	done
}

#Main script.
main() {
	get_pars "${@}"
	get_hosts
	get_job
	execute_job
	exit 0
}

main "${@}"
