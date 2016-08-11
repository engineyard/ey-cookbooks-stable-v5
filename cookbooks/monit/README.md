monit
========

# Overview

This recipe installs monit. We use monit to ensure that certain processes are always running, restart them in case they die unexepectedly, and to enforce memory usage limits.

Some examples:

On app instances, we use monit to ensure that Unicorn or php-fpm are always running. We also use it to terminate Unicorn workers that have exceeded their memory limit.

On utility instances for background workers, we use monit to ensure that resque or sidekiq is always running, and also to terminate workers that have exceeded the memory limit.

# Recipe Details

This recipe installs the version specified in node.dna['monit']['version']. This can be overriden by setting `monit_ebuild_version` in the account metadata to install a specific version.

The recipe creates the monit configuration file in `/etc/monitrc` and adds an inittab entry so that monit is started every time it dies.

`monit` expects the `*.monitrc` configuration files to be in `/etc/monit.d` but these are actually symlinked to `/data/monit.d`. This way the monit configuration files are included in the `/data` snapshots.
