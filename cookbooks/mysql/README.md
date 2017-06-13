mysql
========

A chef recipe for managing the installed version of MySQL server and client tools on EngineYard AppCloud. This recipe uses installs from the internal Engine Yard Portage tree (Gentoo). Includes support for installing MySQL client tools for working with RDS MySQL as well as RDS Aurora and RDS MariaDB.

dependencies
============

- ebs - manages the attachment and formatting of EBS volumes, and physical backup scheduling
- ey-lib - provides internal stack functionality
- ey-backup - establishes logical backup scheduling
- db-ssl - generates and distributes ssl keys for database connection encryption _(off by default)_