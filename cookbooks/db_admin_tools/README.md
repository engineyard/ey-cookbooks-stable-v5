db_admin_tools
===

# db\_admin\_tools

Manages the installation and configuration of multiple database related tools depending on the database version in use for the environment.

# MySQL Tools

- `mytop` - a top clone for MySQL that provides an ability to "watch" activity against the database server in real time.
- `innotop` - a mytop clone for InnoDB that provides internal statistics on the function and activity for the InnoDB engine specifically.
- `percona toolkit` - a suite of tools published by [Percona](https://www.percona.com/software/mysql-tools/percona-toolkit) for managing MySQL.
- `oom adjustment` - adjusts internal kernel settings for the OS to make it less likely for the database process to be killed in the event of a low memory condition.
- `binary_log_purge` - a purpose built tool designed to monitor the position of attached replicas (relative to the master) and only remove binary logs that have been successfully processed by all replicas. [More](https://support.cloud.engineyard.com/hc/en-us/articles/205408138-MySQL-Tools-Reference).

# PostgreSQL Tools

- `pg_top` - a top clone for PostgreSQL that provides an ability to "watch" activity against the database server in real time.
- `oom adjustment` - adjusts internal kernel settings for the OS to make it less likely for the database process to be killed in the event of a low memory condition.
