# custom-papertrail

The papertrail Cookbook downloads and setups papertrail in your instances. This
cookbook shows how to wrap the cookbook to customize it.

## Installation

For simplicity, we recommend that you create the `cookbooks/` directory at the
root of your application. If you prefer to keep the infrastructure code separate
from application code, you can create a new repository.

Our main recipes have the `papertrail` Cookbook but it is not included by default.
To use the `papertrail` cookbook, you should copy this cookbook
`custom-papertrail`. You should not copy the actual `papertrail` recipe as
That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

        include_recipe 'custom-papertrail'

2. Edit `cookbooks/ey-custom/metadata.rb` and add

        depends 'custom-papertrail'

3. Copy `custom-cookbooks/sidekiq/cookbooks/custom-papertrail` to `cookbooks/`

        cd ~ # Change this to your preferred directory. Anywhere but inside the
             # application

        git clone https://github.com/engineyard/ey-cookbooks-stable-v5
        cd ey-cookbooks-stable-v5
        cp custom-cookbooks/papertrail/cookbooks/custom-papertrail /path/to/app/cookbooks/

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

5. Specify the papertrail port and endpoint in
   `cookbooks/custom-papertrail/attributes/default.rb`:

        default['papertrail']['destination_host'] = 'host1.papertrailapp.com'
        default['papertrail']['port'] = 1235

If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`custom-cookbooks/papertrail/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

## Customizations

All customizations go to `cookbooks/custom-papertrail/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the papertrail recipe configures all instances in the environment. You can change this using `node['dna']['instance_role']` and `node['dna']['instance_role'] `.

```ruby
# this is the default
default['papertrail']['is_papertrail_instance'] = true

# run the recipe on a utility instance named papertrail (see comments in custom-papertrail/attributes/default.rb)
default['papertrail']['is_papertrail_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'papertrail')

# run the recipe on a solo instance
default['papertrail']['is_papertrail_instance'] = (node['dna']['instance_role'] == 'solo')
```

### Specify the logs to monitor

    # this is the default
    default['papertrail']['other_logs'] = [
      '/var/log/engineyard/nginx/*log',
      '/var/log/engineyard/apps/*/*.log',
      '/var/log/mysql/*.log',
      '/var/log/mysql/mysql.err',
    ]

    # Only logs from Chef runs
    default['papertrail']['other_logs'] = [
      '/var/log/chef.log'
    ]
