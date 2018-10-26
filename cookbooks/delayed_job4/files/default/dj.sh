#!/bin/sh
#
# This script starts and stops the Dj daemon
# This script is created by the delayed_job4 recipe
# This script belongs in /engineyard/custom/dj
#
# Updated for Rails 4.x

PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH
CURDIR=`pwd`
export NEW_RELIC_DISPATCHER=delayed_job

usage() {
  echo "Usage: $0 <appname> {start|stop} enviroment [-n WORKER_NAME] [-p MIN_PRIORITY] [-P MAX_PRIORITY] [-q comma,separated,queues]"
  exit 1
}

die() {
  echo -e "fatal error: ${1}" 1>&2
  ! [ "$(echo ${0} | awk -F/ '{print $NF}')" == "bash" ] && exit 255 || return 255
}

defined() {
  [ -n "${1}" ]
}

exists() {
  defined "${1}" || die "exists - No path given."
  [ -e "${1}" ]
}

is_file() {
  defined "${1}" || die "is_file - No path given."
  exists "${1}" && [ -f "${1}" ]
}

is_directory() {
  defined "${1}" || die "is_directory - No path given."
  exists "${1}" && [ -d "${1}" ]
}

add_arg() {
  local argname="${1}"
  local argcontent="${2}"
  local original="${3}"

  # Make no changes if the content to add is empty
  if ! defined "${argcontent}"
  then
    echo -n "${original}"
    return
  fi

  local arg="'${argname}=${argcontent}'"

  if defined "${original}"
  then
    original="${arg}, ${original}"
  else
    original="${arg}"
  fi

  echo -n "${original}"
}

start() {
  local app_name=${1}
  local app_root="/data/${app_name}/current"
  local rails_env=${3}

  # Clear out the non-option stuff so getopts doesn't freak out
  shift 3

  local queues="${QUEUES}"
  local worker_name=""
  local min_priority=""
  local max_priority=""
  local OPTIND=1

  while getopts ":n:p:P:q:" opt
  do
    case $opt in
      n)
        worker_name="${OPTARG}"
        ;;
      q)
        if defined "${queues}"
        then
          queues="${queues},${OPTARG}"
        else
          queues=${OPTARG}
        fi
        ;;
      p)
        min_priority=${OPTARG}
        ;;
      P)
        max_priority=${OPTARG}
        ;;
      :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
    esac
  done

  # Sanitize the worker name
  if ! defined "${worker_name}"
  then
    worker_name = 'nil'
  fi

  # Sanitize the queues (whitespace -> comma)
  if defined "${queues}"
  then
    queues="$(echo "${queues}" | sed -e 's/[[:space:]]/,/g')"
  fi

  local worker_options=""
  worker_options="$(add_arg "--queues" "${queues}" "${worker_options}")"
  worker_options="$(add_arg '--max-priority' "${max_priority}" "${worker_options}")"
  worker_options="$(add_arg '--min-priority' "${min_priority}" "${worker_options}")"

  echo "worker_options == \"${worker_options}\""
}

stop() {
  echo "stop got '${@}'"
}

main() {
  if [ $# -lt 3 ]
  then
    usage
  fi

  local app_name=$1
  local action=$2
  local app_root="/data/${app_name}/current"
  local rails_env=$3

  if ! is_directory "${app_root}"
  then
    echo "${app_root} doesn't exist"
    usage
  fi

  case "${action}" in
    start)
      start ${@}
      ;;
    stop)
      stop ${@}
      ;;
    *)
      echo "Unknown action '${action}'"
      usage
      ;;
  esac
}

main $@
