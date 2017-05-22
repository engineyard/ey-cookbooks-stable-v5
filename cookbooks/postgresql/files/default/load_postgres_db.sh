#!/bin/bash

set -o errexit

usage="
Usage: ${0} [-h] <dumpfile> <dbname> [dbuser]

-h          This help listing
<dumpfile>  The dump file path.
<dbname>    The db name.  Typically the same as the application name.
[dbuser]    An optional db user to use for setting ownership of the db.
            If this is supplied the user must already exist on the db server.
            Default: deploy
"

if [[ -z "${1}" || -z "${2}" || "${1}" = "-h" ]]
then
    echo "${usage}"
    exit
fi

dump_file=$1
app_name=$2
[[ -z "${3}" ]] && db_user='deploy' || db_user=${3}

if [ ! -f "${dump_file}" ]
then
    echo "${dump_file} does not exist."
    exit 1
fi

function check_continue() {
    prompt_message=${1}
    echo -e -n "${prompt_message}\n\nContinue? (y/n) "
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
}

set +o errexit
psql -U postgres -t -c"SELECT rolname FROM pg_roles WHERE rolname = '${db_user}';" | grep -q "${db_user}" > /dev/null 2>&1
res=$?
set -o errexit

if [ "$res" != "0" ]
then
    check_continue "\n${db_user} database user not found.  We'll need to create it to continue."

    while true;
    do
        read -p "Password for new user (required): " new_pass

        if [ -z "${new_pass}" ]
        then
            echo "Non-zero length password required."
            continue
        fi

        read -p "One more time for posterity: " repeat
        if [ "${repeat}" != "${new_pass}" ]
        then
            echo "Passwords do not match!"
            continue
        fi
        break
    done
    psql -U postgres -c"CREATE USER ${db_user} WITH ENCRYPTED PASSWORD '${new_pass}';"
fi

set +o errexit
psql -U postgres -t -c"SELECT datname FROM pg_database WHERE datname = '${app_name}';" | grep -q "${app_name}" > /dev/null 2>&1
res=$?
set -o errexit
if [ "$res" = "0" ]
then
    # Warn & prompt before continuing
    check_continue "\nWARNING: ${app_name} database found.  To continue we will drop and recreate the ${app_name} database!"

    # kill any active connections on ${app_name} db
    echo "Killing active connections on ${app_name} before dropping it."
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

    # start fresh and make the app user the owner of the public schema
    echo "Dropping the ${app_name} database."
    dropdb -U postgres ${app_name}
else
    check_continue "\n${app_name} database not found. To continue we'll need to create it."
fi

echo -e "\nCreating the ${app_name} dataabase."
createdb -U postgres -O ${db_user} ${app_name}

# is this a custom dump?
set +e
pg_restore -l ${dump_file} > /dev/null 2>&1
res=$?
set -e

# load the dump
echo -e "\nRestoring ${dump_file} to the ${app_name} database."
if [ "${res}" = "0" ]
then
    pg_restore -d ${app_name} --no-owner --no-privileges -U postgres ${dump_file}
else
    psql -U postgres -f ${dump_file} ${app_name}
fi

function gen_run_queries() {
    psql -U postgres -t -c "${gen_query}" ${app_name} | psql -U postgres ${app_name}
}

# fix ownership of all tables, views, and sequences to the app user
echo -e "\nSetting ownership of all relations from ${dump_file} to ${db_user}."
gen_query="
SELECT 'ALTER ' || CASE t.relkind
                    WHEN 'r' THEN 'TABLE '
                    WHEN 'S' THEN 'SEQUENCE '
                    WHEN 'v' THEN 'VIEW '
                    WHEN 'm' THEN 'MATERIALIZED VIEW '
                    END || n.nspname || '.' || t.relname || ' OWNER TO ${db_user};'
FROM pg_class t, pg_namespace n
WHERE t.relnamespace=n.oid
    AND n.nspname != 'information_schema' AND n.nspname NOT LIKE E'pg\_%'
    AND (t.relkind IN ('r', 'v', 'm') OR
         -- this is a filter for sequences not owned by tables
         (t.relkind = 'S'
            AND t.oid NOT IN (SELECT d.objid
                            FROM pg_depend d, pg_class t
                            WHERE d.refobjid = t.oid
                              AND t.relkind = 'r')))
ORDER BY relkind, relname;"
gen_run_queries

# fix the ownership of all the schemas to be the app user
echo -e "\nSetting ownership of all schemas from ${dump_file} to ${db_user}."
gen_query="
SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO ${db_user};'
FROM pg_namespace
WHERE nspname != 'information_schema' AND nspname NOT LIKE 'pg_%';"
gen_run_queries

# fix the ownership of all non-system functions and aggregates to the app user
echo -e "\nSetting ownership of all user-defined functions and aggregates from ${dump_file} to ${db_user}."
gen_query="
SELECT 'ALTER ' || CASE p.proisagg
                    WHEN TRUE THEN ' AGGREGATE '
                    ELSE ' FUNCTION '
                   END || n.nspname || '.' || p.proname || '('
    || pg_catalog.array_to_string(ARRAY(
              SELECT pg_catalog.format_type(p.proargtypes[s.i], NULL)
              FROM
                pg_catalog.generate_series(0, pg_catalog.array_upper(p.proargtypes, 1)) AS s(i)), ', ')
    || ') OWNER TO ${db_user};'
FROM pg_proc p, pg_namespace n
WHERE p.pronamespace = n.oid
    AND n.nspname != 'information_schema' AND n.nspname NOT LIKE E'pg\_%';"
gen_run_queries

echo -e "\nSetting ownership of all user-defined types from ${dump_file} to ${db_user}."
gen_query="
SELECT 'ALTER TYPE ' || n.nspname || '.' || typname || ' OWNER TO ${db_user};'
FROM pg_type t, pg_namespace n
WHERE n.nspname != 'information_schema' AND n.nspname NOT LIKE 'pg_%'
    AND t.typnamespace = n.oid
    AND t.typname NOT LIKE '\_%'
    AND (t.typrelid = 0 OR (SELECT TRUE
                            FROM pg_class c
                            WHERE c.oid = t.typrelid AND c.relkind = 'c'));"
gen_run_queries
