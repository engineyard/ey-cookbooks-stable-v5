ephemeraldisk
========

Configures up to the first two ephemeral disks of any given instance and attaches them as /tmp/eph1 and /tmp/eph2 if they exist and are over 28GB in size. These devices are temporary volumes associated with the underlying host instance and do not get backed up or restored if the instance is rebuilt. These volumes are only available for certain instance types. Engine Yard does not currently store any data on these volumes.
