postgresql
========

A chef recipe for managing the installed version of PostgreSQL server and client tools on EngineYard AppCloud. This recipe uses installs from the internal Engine Yard Portage tree (Gentoo). Includes support for installing PostgreSQL client tools for working with RDS PostgreSQL.

dependencies
============

- ebs - manages the attachment and formatting of EBS volumes, and physical backup scheduling
- ey-lib - provides internal stack functionality
- ey-backup - establishes logical backup scheduling

Extensions
==========

Postgres core extensions can be specified for a database by either:

- Creating /db/postgresql/extensions.json with the following format (double quotes `"` and hard brackets `[` are required):

    ```
    {
      "dbname": ["ext_name", ...],
      ....
    }
    ```
    
- Using the pg_extension custom resource directly in a cookbook:

    ```
    pg_extension 'resource block name' do
      ext_name [String, Array] # required, either a single extension name or multiple in an array
      db_name [String, Array] # required, either a single db name or multiple in an array
      schema_name String # optional, name of schema to install extension(s) to, must be present in all db specified in db_name
      version String # optional, version of extension to install, only applicable if single ext_name is given
      old_version # optional, for replacing old style non-extension contrib package
    end
    ```
    
See PostgreSQL CREATE EXTENSION docs for full explanation of schema_name, version, and old_version