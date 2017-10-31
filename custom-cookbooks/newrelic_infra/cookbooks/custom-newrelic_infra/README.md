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

Please make sure to specify the license key in custom-newrelic_infra/attributes/default.rb:

```ruby
# Replace value with actual license key
default['newrelic_infra']['license_key'] = "INSERT_NEW_RELIC_INFRA_KEY"
```

This will be used in generating /etc/newrelic-infra.yml.

### Package Version

The recipe downloads the New Relic Infrastructure .deb package version as specified in the attributes/default.rb. Please update the version number as necessary:

```ruby
default['newrelic_infra']['package_version'] = "1.0.785"
```
