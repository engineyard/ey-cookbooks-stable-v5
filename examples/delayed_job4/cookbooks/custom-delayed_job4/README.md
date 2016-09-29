# Custom Delayed Job

The delayed_job4 recipe creates a dj script that runs delayed job and a monit config file. Each application on the environment will get its own Delayed Job workers.

You need to add the delayed_job gem to your app.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `delayed_job4` recipe but it is not included by default. To use the `delayed_job4` recipe, you should copy this recipe `custom-delayed_job4`. You should not copy the actual `delayed_job4` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-delayed_job4'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-delayed_job4'
      ```

3. Copy `examples/delayed_job4/cookbooks/custom-delayed_job4` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp examples/delayed_job4/cookbooks/custom-delayed_job4 /path/to/app/cookbooks/
      ```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy `examples/delayed_job4/cookbooks/ey-custom` to `/path/to/app/cookbooks`.

## Customizations

All customizations go to `cookbooks/custom-delayed_job4/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the delayed_job4 recipe runs on a utility instance named `delayed_job`. You can change this using `node['dna']['instance_role']` and `node['dna']['instance_role'] `. 

```ruby
# this is the default
default['delayed_job4']['is_dj_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'delayed_job')

# run the recipe on a utility instance named background_workers
default['delayed_job4']['is_dj_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'background_workers')

# run the recipe on a solo instance
default['delayed_job4']['is_dj_instance'] = (node['dna']['instance_role'] == 'solo')
```

### Choose the applications that have delayed job

By default, all applications in an environment will have Delayed Job workers. You can change this by specifying an array of application names.

If you only have one application, you don't need to make any changes to `default['delayed_job4']['applications']`.

```ruby
# this is the default
# get all applications
default['delayed_job4']['applications'] = 'applications' => node['dna']['applications'].map{|app_name, data| app_name}

# specify the application name
default['delayed_job4']['applications'] = %w[todo]
```

### Choose the number of Delayed Job workers

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
default['delayed_job4']['worker_count'] = worker_count

# specify the number of workers
default['delayed_job4']['worker_count'] = 4
```

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping your application and rebuilding your instances (i.e. running chef) are not always done at the same time. It is best to restart your Delayed Job workers when you ship (deploy) your application code.

If you're running Delayed Job on a solo instance or on your app master, add a deploy hook similar to:

```
on_app_master do
  sudo "monit -g dj_#{config.app} restart all"
end
```

On the other hand, if you'r running Delayed Job on a dedicated utility instance, the deploy hook should be like:

```
on_utilities :delayed_job do
  sudo "monit -g dj_#{config.app} restart all"
end
```

where delayed_job is the name of the utility instance.

You likely want to use the after_restart hook for this. Put the code above in `deploy/after_restart.rb`.

See our [Deploy Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks) documentation for more information on using deploy hooks.
