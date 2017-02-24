# Timezone

This cookbook makes it easy to change the timezone of your instances to one that
suits your geographical location, rather than the default UTC zone.

## Installation

For simplicity, we recommend that you create the `cookbooks/` directory at the
root of your application. If you prefer to keep the infrastructure code separate
from application code, you can create a new repository.

Our main recipes have the `timezone` cookbook but it is not included by default.
To use the `timezone` cookbook, you should copy this cookbook
`custom-timezone`. You should not copy the actual `timezone` recipe as
this is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

    include_recipe 'custom-timezone'

2. Edit `cookbooks/ey-custom/metadata.rb` and add

    depends 'custom-timezone'

3. Copy `custom-cookbooks/timezone/cookbooks/custom-timezone` to `cookbooks/`

    cd ~ # Change this to your preferred directory. Anywhere but inside the application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp custom-cookbooks/timezone/cookbooks/custom-timezone /path/to/app/cookbooks/

If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`custom-cookbooks/timezone/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

## Specifying the Zone

The recipe has 'UTC' as an example timezone setting so it will not do anything since the
server timezone is UTC by default. Make sure you change it as necessary before using.

Set the timezone in `cookbooks/custom-timezone/attributes/default.rb`.

## Restarting Services

Our main timezone recipe only restarts 3 services (cron, sysklogd, and nginx) when this recipe runs and changes the timezone so that the services are aware of the new timezone. If you find that you need other system services to be restarted, make sure you find the appropriate script in /etc/init.d, and add the names in `cookbooks/custom-timezone/attributes/default.rb`.

## Restarting Databases

**Masters**

The database uses system time by default and will need to be restarted after applying this change. We recommend that the master database be restarted by hand rather than through this recipe so that the downtime associated with that can be managed as part of a planned maintenance. Additional information on restarting databases can be found here: https://support.cloud.engineyard.com/entries/21016413-Troubleshoot-Your-Database.

**Replicas**

When adding new replicas to your environment the replica database will start before your custom chef updates the timezone configuration. As a result you will need to restart your database on new replicas after the initial chef run completes successfully.
