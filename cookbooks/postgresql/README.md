postgresql
========

A chef recipe for managing the installed version of PostgreSQL server and client tools on EngineYard AppCloud. This recipe uses installs from the internal Engine Yard Portage tree (Gentoo). Includes support for installing PostgreSQL client tools for working with RDS PostgreSQL.

dependencies
============

- ebs - manages the attachment and formatting of EBS volumes, and physical backup scheduling
- ey-lib - provides internal stack functionality
- ey-backup - establishes logical backup scheduling