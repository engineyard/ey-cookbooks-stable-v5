#!/bin/bash

# make tmp dir
status_dir="/tmp/check_readonly_status"
mkdir -p "${status_dir}"

# alert
alert () 
{
  # params
  device="${1}"; severity="${2}"
  timestamp=$(date '+%s')

  # load previous status
  status_file="${status_dir}/device${device//\//-}-status"
  previous_severity=$(cat "${status_file}") 2>/dev/null 

  # send notification
  if [[ $severity != $previous_severity ]]; then
    case "${severity}" in
      OKAY) message="The device mounted at ${device} is writable" ;;
      FAILURE) message="The device mounted at ${device} is read only" ;;
    esac
    
    echo "PUTNOTIF Type=device-status Time=${timestamp} Severity=${severity} Message=\"raw_message: ${message}\""
  fi
  
  # write current status to status file
  echo "${severity}" > "${status_file}"
}

# check for readonly volumes  
for device in $(awk 'NR>1{print $2}' /proc/mounts); do
  severity=$(awk "\$2==\"${device}\"{if(\$4~/(^|,)ro($|,)/){s=\"FAILURE\"}else{s=\"OKAY\"}};END{print s}" /proc/mounts)
  alert "${device}" "${severity}"
done
