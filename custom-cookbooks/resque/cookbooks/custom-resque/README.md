# Custom Resque

The resque recipe creates a resque script and a monit config file. Each application on the environment will get its own Resque workers.

You need to add the resque gem to your app.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `resque` recipe but it is not included by default. To use the `resque` recipe, you should copy this recipe `custom-resque`. You should not copy the actual `resque` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-resque'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-resque'
      ```

3. Copy `custom-cookbooks/resque/cookbooks/custom-resque` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/resque/cookbooks/custom-resque /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

      ```
      gem install ey-core
      ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
      ```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy `custom-cookbooks/resque/cookbooks/ey-custom` to `/path/to/app/cookbooks`.

## Dependencies

`resque` depends on Redis. We recommend using the [Redis recipe](https://github.com/engineyard/ey-cookbooks-stable-v5/tree/master/cookbooks/redis) to setup Redis on the environment.

## Customizations

All customizations go to `cookbooks/custom-resque/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the resque recipe runs on a utility instance named `resque` or on a solo instance. You can change this using `node['dna']['instance_role']` and `node['dna']['instance_name'] `.

```ruby
# this is the default
default['resque']['is_resque_instance'] = (node['dna']['instance_role'] == 'solo') || (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'resque')

# run the recipe on a utility instance named background_workers
default['resque']['is_resque_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'background_workers')

# run the recipe on a solo instance only
default['resque']['is_resque_instance'] = (node['dna']['instance_role'] == 'solo')
```

### Choose the applications that have resque

By default, all applications in an environment will have Resque workers. You can change this by specifying an array of application names.

If you only have one application, you don't need to make any changes to `default['resque']['applications']`.

```ruby
# this is the default
# get all applications
default['resque']['applications'] = 'applications' => node['dna']['applications'].map{|app_name, data| app_name}

# specify the application name
default['resque']['applications'] = %w[todo]
```

### Choose the number of Resque workers

By default, we use the instance type to determine the number of workers. This is good for most cases as the number of workers adjust when you upgrade to a larger instance type with more memory and CPU.

```ruby
# this is the default
# this is an incomplete list of instance types
# the numbers here are only a guide and should be adjusted depending on your app
worker_count = if node['dna']['instance_role'] == 'solo'
                 1
               else
                 case node['ec2']['instance_type']
                 when 'm3.medium' then 2
                 when 'm3.large' then 4
                 when 'm3.xlarge' then 8
                 when 'm3.2xlarge' then 8
                 when 'c3.large' then 4
                 when 'c3.xlarge' then 8
                 when 'c3.2xlarge' then 8
                 when 'm4.large' then 4
                 when 'm4.xlarge' then 8
                 when 'm4.2xlarge' then 8
                 when 'c4.large' then 4
                 when 'c4.xlarge' then 8
                 when 'c4.2xlarge' then 8
                 else # default
                   2
                 end
               end
default['resque']['worker_count'] = worker_count

# specify the number of workers
default['resque']['worker_count'] = 4
```

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping your application and rebuilding your instances (i.e. running chef) are not always done at the same time. It is best to restart your Resque workers when you ship (deploy) your application code.

If you're running Resque on a solo instance or on your app master, add a deploy hook similar to:

```
on_app_master do
  sudo "monit -g #{config.app}_resque restart all"
end
```

On the other hand, if you'r running Resque on a dedicated utility instance, the deploy hook should be like:

```
on_utilities :resque do
  sudo "monit -g #{config.app}_resque restart all"
end
```

where resque is the name of the utility instance.

You likely want to use the after_restart hook for this. Put the code above in `deploy/after_restart.rb`.

See our [Deploy Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks) documentation for more information on using deploy hooks.

You can also stop the Resque workers at the start of the deploy if necessary. Check https://support.cloud.engineyard.com/hc/en-us/articles/205407428-Configure-and-Deploy-Resque for more information.
