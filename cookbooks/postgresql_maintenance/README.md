ey-cloud-recipes/postgresql_maintenance
------------------------------------------------------------------------------

A chef recipe for enabling a maintenance tasks for Postgresql on Engine Yard Cloud. Currently this recipe consists of setting up a vacuumdb cron job for a PostgreSQL database that can be customized to a specific application need (see below). This recipe may be updated in the future to support additional maintenance options.


Dependencies
--------------------------

These recipes are designed and build for use with PostgreSQL.


VacuumDB
--------------------------

Your database is configured by default with autovacuum but minimizes resources to this process to prevent it from negatively impacting application performance. Databases that see regular heavy load, or lots of writes and deletes may need regular manual vacuum operations globally or for specific tables. 

The default action for the recipe will set up a weekly vacuum of all databases on the server at midnight Saturday night/Sunday morning server time.  If that is sufficient then you can simply enable this cookbook in the same manner as the redis example in the /examples folder of this repo.  If you need to customize the run time or vacuumdb command then place the changes to the attributes in attributes/default.rb in the custom_postgresql_maintenance wrapper cookbook's attributes/default.rb and enable that cookbook instead.  (See this short article for how that works: https://blog.chef.io/2013/12/03/doing-wrapper-cookbooks-right/)

Additional information on vacuum operation can be found in the PostgreSQL Manual: http://www.postgresql.org/docs/9.3/static/sql-vacuum.html.
