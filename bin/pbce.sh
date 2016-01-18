#!/bin/bash
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Poor Basterds Command Executer execute connamds on remote Linux systems.

#Script variables.
pbce_dir='/home/l-fallback/jelle/pbce'
fqdn_regex='^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$'
ip_regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'

#Script functions.
help() {
	echo help
}

get_pars() {
	if [ -z "${1}" ]; then
		help
		exit 99
	else
		while getopts Hh:j: n
		do
			case "${n}" in
			H)
				help
				exit 99
				;;
			h)
				host="${OPTARG}"
				;;
			j)
				job="${OPTARG}"
				;;
			*)
				help
				exit 99
			esac
		done
	fi
}

check_host() {
	if [[ $1 =~ $fqdn_regex || $1 =~ $ip_regex ]]; then
		true
	else
		echo "$me: $1 not a valid fqdn or IP address"
		exit 99
	fi
}

get_hosts() {
	if [[ ${host} = all ]]; then
		hosts=( $(grep -H -F 'hostname=' "${pbce_dir}"/hosts/*.conf | \
		awk -F\: '{print $1}') )
	else
		hosts=( $(grep -F -H "groupname='${host}'" \
		"${pbce_dir}"/hosts/*.conf | awk -F\: '{print $1}') )
		if [[ -z "${hosts}" ]]; then
			hosts=( $(grep -H -F "hostname='${host}'" \
			"${pbce_dir}"/hosts/*.conf | \
			awk -F\: '{print $1}') )
		fi
	fi
	if [[ -z ${hosts} ]]; then
		echo "$me: no hosts found"
		exit 99
	else
		for h in "${hosts[@]}"; do
			h="$(grep -F 'hostname=' "$h" | awk -F\' '{print $2}')"
			check_host "$h"
		done
	fi
}

check_job() {
	job_type="$(file "$1" | awk '{print $2}')"
	if [[ ${job_type} != Bourne-Again ]]; then
		echo "${me}: ${1} not a Bourne-Again shell script"
		exit 99
	fi
}

get_jobs() {
	if [[ ${job} = all ]]; then
		jobs=( $(grep -H -F 'jobname=' "${pbce_dir}"/jobs/*.sh | \
		awk -F\: '{print $1}') )
	else
		jobs=( $(grep -H -F "jobgroup='${job}'" \
		"${pbce_dir}"/jobs/*.sh | awk -F\: '{print $1}') )
		if [[ -z ${jobs} ]]; then
			jobs=( $(grep -H -F "jobname='${job}" \
			"${pbce_dir}"/jobs/*.sh | \
			awk -F\: '{print $1}') )
		fi
	fi
	if [[ -z ${job} ]]; then
		echo "$me: no jobs found"
		exit 99
	else
		for h in "${jobs[@]}"; do
			check_job "$h"
		done
	fi
}

make_script() {
	config64="$(base64 -w0 ${1})"
	functions64="$(base64 -w0 "${pbce_dir}/functions/functions.sh")"
	i=0
	for j in "${jobs[@]}"; do
		jobs64[$i]="$(base64 -w0 "${j}")"
		(( i++ ))
	done
	if [[ -z "${config64}" || -z "${functions64}" || -z "${jobs64}" ]]; then
		echo "$me: failed to compile script"
		exit 99
	else
		final_script="${config64}${functions64}${jobs64[@]}"
	fi
}

get_vars() {
	sshuser="$(grep -F 'sshuser=' "$1" | awk -F\' '{print $2}')"
	hostname="$(grep -F 'hostname=' "$1" | awk -F\' '{print $2}')"
	if [[ -z "$sshuser" || -z "$hostname" ]]; then
		echo "$me: failed get hostname or sshuser from $1"
		exit 99
	fi
}

execute_jobs() {
	for h in "${hosts[@]}"; do
		make_script "$h"
		get_vars "$h"
		echo "Working on $hostname"
		ssh -q -o StrictHostKeyChecking=no "$sshuser@$hostname" \
		echo "${final_script} | base64 -d | sudo bash"
		if [[ ! $? -eq 0 ]]; then
			echo "$me: Something went wrong on host ${hostname}"
			exit 99
		fi
	done
}

#Main script.
main() {
	get_pars "$@"
	get_hosts
	get_jobs
	execute_jobs
}

main "$@"
