# custom_sidekiq

The sidekiq Cookbook creates a sidekiq script that runs Sidekiq and a monit
config file. Each application on the environment will get its own sidekiq
workers.

You need to add the sidekiq gem to your app.

## Installation

For simplicity, we recommend that you create the `cookbooks/` directory at the
root of your application. If you prefer to keep the infrastructure code separate
from application code, you can create a new repository.

Our main recipes have the `sidekiq` Cookbook but it is not included by default.
To use the `sidekiq` cookbook, you should copy this cookbook
`custom-sidekiq`. You should not copy the actual `sidekiq` recipe as
this is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

    include_recipe 'custom-sidekiq'

2. Edit `cookbooks/ey-custom/metadata.rb` and add

    depends 'custom-sidekiq'

3. Copy `examples/sidekiq/cookbooks/custom-sidekiq` to `cookbooks/`

    cd ~ # Change this to your preferred directory. Anywhere but inside the
         # application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp examples/sidekiq/cookbooks/custom-sidekiq /path/to/app/cookbooks/

If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`examples/sidekiq/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

## Customizations

All customizations go to `cookbooks/custom_sidekiq/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the sidekiq recipe runs on all instances. You can change this
using `node['dna']['instance_role']` and `node['dna']['name'] `. 

    # this is the default
    default['sidekiq']['is_sidekiq_instance'] = true

    # run the recipe on a utility instance named background_workers
    default['sidekiq']['is_sidekiq_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'background_workers')

    # run the recipe on a solo instance
    default['sidekiq']['is_sidekiq_instance'] = (node['dna']['instance_role'] == 'solo')

### Choose the number of Sidekiq processes

By default, we set the number of Sidekiq processes to 1. The following change
will automatically adjust the number of workers when you upgrade to a
larger instance type with more memory and CPU:

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
    default['sidekiq']['workers'] = worker_count

    # specify the number of workers
    default['sidekiq']['workers'] = 4

### Set the worker memory limit

Monit keeps track of your Sidekiq workers and by default, it restarts workers exceeding 400MB of memory.

```ruby
# specify custom memory limit
default['sidekiq']['worker_memory'] = 450
```

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping
your application and rebuilding your instances (i.e. running chef) are not
always done at the same time. It is best to restart your Sidekiq workers
when you ship (deploy) your application code.

If you're running Sidekiq on a solo instance or on your app master, add a deploy
hook similar to:

    on_app_master do
      sudo "monit -g sidekiq_#{config.app}_0 restart all"
    end

On the other hand, if you'r running Sidekiq on a dedicated utility instance, the
deploy hook should be like:

    on_utilities :sidekiq do
      sudo "monit -g sidekiq_#{config.app}_<worker_id> restart all"
    end

where `sidekiq` is the name of the utility instance.

You likely want to use the after_restart hook for this. Put the code above in
`deploy/after_restart.rb`.

See our [Deploy
Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks)
documentation for more information on using deploy hooks.
