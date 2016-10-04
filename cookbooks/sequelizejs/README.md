Sequelize Cookbook for Engine Yard Cloud
==========

[Sequelize][1] is an easy-to-use multi sql dialect ORM for Node.js & io.js. It currently supports MySQL, MariaDB, SQLite, PostgreSQL and MSSQL.

Enabling this recipe
----------

* Edit sequelizejs/attributes/default.rb.
* Edit ey-custom/metadata.rb and add the line: `depends 'sequelizejs'`.
* Edit ey-custom/recipes/after-main.rb and the following line:

```
include_recipe "sequelizejs"
```

[1]: http://sequelizejs.com
