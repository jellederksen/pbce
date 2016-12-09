#!/bin/bash
#
#Turn off password aging for

jobname='PasswdAgingOff'

passwd_aging_off() {
       users=( $(awk -F: '{print $1","$3","$6}' /etc/passwd))
       if [[ -z $users ]]; then
                echo 'no users found in passwd'
                exit 99
       fi
       for i in "${users[@]}"; do
               #n = username; u = account uid; h = user home directory
               while IFS=',' read n u h; do
                       if [[ $u -lt 500 ]]; then
                               continue
                       fi
                       #z = username, p = password hash, r = rest
                       grep "^${n}:" /etc/shadow | while IFS=':' read z p r; do
                               if [[ -z ${z} ]]; then
                                       echo "no shadow entry found for ${n}"
                                       exit 99
                               fi
                               if [[ ${n} != ${z} ]]; then
                                       echo "namecheck failed $n and $z"
                                       exit 99
                               fi
                               if [[ ${p} == '!!' ]]; then
                                       [[ $(chage -l "${n}" | grep 'Password expires' |  sed 's/\t\t*//' | awk '{print $3}') == never ]] && continue
                                       if grep '^ssh' "${h}/.ssh/authorized_keys" > /dev/null 2>&1; then
                                               chage -l "${n}" | grep 'Password expires' | sed 's/\t\t*//' | tr '\n' ' ' ; echo "for user: ${n}"
                                               if ! chage -I -1 -m 0 -M 99999 -E -1 "${n}"; then
                                                       echo "failed to change password expiration for ${n}"
                                                       exit 99
                                               fi
                                       fi
                               fi
                       done
               done<<<"$i"
       done
}

main() {
        check_root
        check_os
        passwd_aging_off
        exit 0
}

main "${@}"
