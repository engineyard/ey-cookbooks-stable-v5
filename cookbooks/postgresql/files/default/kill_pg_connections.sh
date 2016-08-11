#!/bin/bash

set -e

usage="
Usage: ${0} [-h] <dbname>

-h          This help listing
<dbname>    The db name with connections to kill.  Typically the same as the application name.
"

if [[ -z "${1}" ||"${1}" = "-h" ]]
then
    echo "${usage}"
    exit
fi

app_name=$1

# Warn & prompt before continuing
echo -e -n "WARNING: Running this script will kill all connections to the ${app_name} database!\n\nContinue? (y/n) "
while read;
do
    if [ "${REPLY}" = 'y' ]
    then
        break
    fi

    if [ "${REPLY}" = 'n' ]
    then
        exit 0
    fi

    echo -e -n "Please, enter 'y' for yes or 'n' for no.\n\nContinue? (y/n)"
done

# kill any active connections on ${app_name} db

echo "Killing active connections on ${app_name}"
active_pg_version="$(eselect postgresql show)"
[[ "$active_pg_version" > "9.1" ]] && col='pid' || col='procpid';
query="
SELECT $col
FROM pg_stat_activity
WHERE datname='${app_name}';"
for pid in $(psql -U postgres -t -c"$query" postgres);
do
    kill $pid
done
