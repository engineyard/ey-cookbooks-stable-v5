EYCloud Cookbook -- For EngineYard EYCloud
=========

[EYCloud][1] is a PaaS product that utilizes Chef for it's configuration management.  This cookbook should provide the following resources: 

* applications ('applications')

---
Requirements
============

Requires Chef 12 or higher for Lightweight Resource and Provider support.

---
Resources and Providers
=======================

This cookbook provides:

`applications.rb`

`applications.rb`
-------------

Attribute Parameters:

* `name` - required
* `newrelic` - required - defaults to false
* `auth` - false
* `type` - application type
* `repository_uri` - repository_uri
* `repository_branch` - repository_branch
* `repository_revision` - repository_revision
* `http_ports` - http_ports - defaults to 80,443
* `run_deploy` - required
* `deploy_key` - String, Required
* `deploy_action` - action of deploy
* `run_migrations` - required - run migrations

[1]: https://cloud.engineyard.com