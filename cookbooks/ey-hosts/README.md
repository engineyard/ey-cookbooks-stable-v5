ey-hosts
========

Sets up default /etc/hosts file entries for referring to application, database, and utility instances.

###Naming Convention
- App Master: ey-app-master
- App Slave: ey-app-slave[-X]
- DB Master: ey-db-master
- DB Replica: ey-db-slave[-X]
- DB Replica Alternate: ey-db-slave-#{instance_name}[-X]
- Utility: ey-utility-#{instance_name}[-X]

*Note* For [-X], the `-` is only added if an `X` value exists for a given instance. `X` represents a numeric value that reflects a hosts order in the environment DNA and the dashboard. For hosts based on `instance_name` the `X` reflects the index order on the dashboard for hosts with the same `instance_name`.

dependencies
============

- ey-lib - provides internal stack functionality