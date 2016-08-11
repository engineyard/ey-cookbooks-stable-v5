#!/sbin/runscript
# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/nginx/files/nginx-r1,v 1.1 2006/07/04 16:58:38 voxus Exp $

# This file is managed by Chef and will be overwritten on the
# next rebuild.
#
# DO NOT MODIFY
#

#opts="${opts} upgrade reload configtest"
extra_commands="configtest"
extra_started_commands="upgrade reload"

depend() {
        need net
        use dns logger
}

start() {
        configtest || return 1
        ebegin "Starting collectd-httpd"
        start-stop-daemon --start --pidfile /var/run/collectd-httpd.pid \
                --exec /usr/sbin/nginx -- -c /etc/collectd-httpd/collectd-httpd.conf
        eend $? "Failed to start collectd-httpd"
}

stop() {
        configtest || return 1
        ebegin "Stopping collectd-httpd"
        start-stop-daemon --stop --pidfile /var/run/collectd-httpd.pid
        eend $? "Failed to stop nginx"
        rm -f /var/run/collectd-httpd.pid
}

reload() {
        configtest || return 1
        ebegin "Refreshing collectd-httpd' configuration"
        kill -HUP `cat /var/run/collectd-httpd.pid` &>/dev/null
        eend $? "Failed to reload collectd-httpd"
}

upgrade() {
        configtest || return 1
        ebegin "Upgrading collectd-httpd"

        einfo "Sending USR2 to old binary"
        kill -USR2 `cat /var/run/collectd-httpd.pid` &>/dev/null

        einfo "Sleeping 3 seconds before pid-files checking"
        sleep 3

        if [ ! -f /var/run/collectd-httpd.pid.oldbin ]; then
                eerror "File with old pid not found"
                return 1
        fi

        if [ ! -f /var/run/collectd-httpd.pid ]; then
                eerror "New binary failed to start"
                return 1
        fi

        einfo "Sleeping 3 seconds before WINCH"
        sleep 3 ; kill -WINCH `cat /var/run/collectd-httpd.pid.oldbin`

        einfo "Sending QUIT to old binary"
        kill -QUIT `cat /var/run/collectd-httpd.pid.oldbin`

        einfo "Upgrade completed"

        eend $? "Upgrade failed"
}

configtest() {
        ebegin "Checking nginx' configuration"
        /usr/sbin/nginx -c /etc/collectd-httpd/collectd-httpd.conf -t
        eend $? "failed, please correct errors above"
}