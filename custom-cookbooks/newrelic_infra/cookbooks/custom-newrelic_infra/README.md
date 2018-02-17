# Custom New Relic Infrastructure

The newrelic_infra recipe sets up the New Relic Infrastructure agent and a monit config file. This will install the agent in all instances in the environment.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `newrelic_infra` recipe but it is not included by default. To use the `newrelic_infra` recipe, you should copy this recipe `custom-newrelic_infra`. You should not copy the actual `newrelic_infra` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-newrelic_infra'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-newrelic_infra'
      ```

3. Copy `custom-cookbooks/newrelic_infra/cookbooks/custom-newrelic_infra` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/newrelic_infra/cookbooks/custom-newrelic_infra /path/to/app/cookbooks/
      ```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy `custom-cookbooks/newrelic_infra/cookbooks/ey-custom` to `/path/to/app/cookbooks`.

## Customizations

All customizations go to `cookbooks/custom-newrelic_infra/attributes/default.rb`.

### License Key

Please make sure to specify the license key in `custom-newrelic_infra/attributes/default.rb`:

```ruby
# Replace value with actual license key
default['newrelic_infra']['license_key'] = "INSERT_NEW_RELIC_INFRA_KEY"
```

This will be used in generating /etc/newrelic-infra.yml.

If you are using the New Relic account from the New Relic add-on, you can avoid specifying the license key in the attributes file. Please uncomment the following line in `custom-newrelic_infra/attributes/default.rb` to reuse the license key from the add-on:

```ruby
# To use the license key from the New Relic addon, please uncomment the line below:
default['newrelic_infra']['use_newrelic_addon'] = true
```

### Package Version

The recipe downloads the New Relic Infrastructure .deb package version as specified in the `attributes/default.rb`. Please update the version number as necessary:

```ruby
default['newrelic_infra']['package_version'] = "1.0.785"
```

### Display Name

New Relic Infrastructure uses the hostname as the unique identifier for each host. If you prefer to override the auto-generated hostname for reporting, you can specify your own `display_name` in `custom-newrelic_infra/attributes/default.rb`:

```ruby
default['newrelic_infra']['display_name'] = "DISPLAY_NAME"
```

You can dynamically build the display name by using attributes like:

* `node['dna']['instance_role']` - instance role (e.g. "app_master" or "db_slave" or "util")
* `node['dna']['name']` - name of the instance (e.g. "redis" utility instance)
* `node['dna']['environment']['name']` - name of the environment

Please refer to the New Relic Infrastructure configuration documentation:

https://docs.newrelic.com/docs/infrastructure/new-relic-infrastructure/configuration/configure-infrastructure-agent

## Credits

Thanks to [Aviram Radai][1] for showing their recipe on how they installed the New Relic Infrastructure agent in their environment.

[1]: https://github.com/aviramradai
