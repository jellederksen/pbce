#!/bin/bash
#
#Ssh Script Remote Execute
#
#Copyright 2015 Jelle Derksen GNU GPL V3
#Author Jelle Derksen
#Contact jelled@jellederksen.nl
#Website www.jellederksen.nl
#
#Execute a local script on multiple remote systems with the use of ssh. You
#can specify the script you want to execute on the remote systems as the
#first parameter of this script. You don't have to login with the root user
#directly. The user does require the use of sudo.
#
#Example: add a host to remote_hosts array.
#remote_host[0]='192.168.0.1'
#remote_host[1]='192.168.0.2'
#remote_host[2]='192.168.0.3'
#remote_host[3]='192.168.0.4'
#remote_host[4]='192.168.0.5'
#
#Example: set username for ssh login.
#ssh_user='systemadmin'
#
#Example: execute script on remote hosts.
# root # ./ssre.sh <script_you_want_to_execute_remote.sh>

#Script settings change to suit your needs.
remote_host[0]=''
ssh_user=''

#Do not edit below this point.
#Script checks.
if [[ -z "$remote_host" || -z "$ssh_user" ]]; then
	echo 'ssh_user and remote_host not set'
	exit 1
fi

if [[ ! -r "$1" ]]; then
        echo "Enter the script name you want to execute." >&2
        exit 2
else
        base64_script="$(base64 -w0 "$1")"
fi

#Main code.
for x in "${remote_host[@]}"; do
	echo "Ssh to $remote_host and executing script $1."
	ssh -o StrictHostKeyChecking=no "$ssh_user@$x" \
"echo $base64_script | base64 -d | sudo bash"
	if [[ ! "$?" -eq '0' ]]; then
		echo "Someting went wrong on the host $x."
		exit 3
	fi
done

echo "Done executing script on all hosts."
exit 0
