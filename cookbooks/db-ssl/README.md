db-ssl
========

A chef recipe for generating and distributing SSL keys for database connection encryption.

dependencies
============

- ey-lib - provides internal stack functionality

Description
==========

This cookbook generates the SSL keys needed for the server to authenticate users via SSL and a set of application level keys to use from the application when connecting to the database. The keys are generated and installed by default, they will only be enabled on the database if your database was restarted at some point after receiving this update.

<more to follow>