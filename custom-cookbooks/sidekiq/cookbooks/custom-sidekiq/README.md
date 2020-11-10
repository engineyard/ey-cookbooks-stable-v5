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

3. Copy `custom-cookbooks/sidekiq/cookbooks/custom-sidekiq` to `cookbooks/`

    cd ~ # Change this to your preferred directory. Anywhere but inside the
         # application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp custom-cookbooks/sidekiq/cookbooks/custom-sidekiq /path/to/app/cookbooks/

	If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`custom-cookbooks/sidekiq/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

4. Create or modify `config/initializers/sidekiq.rb`:

```
redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env]

Sidekiq.configure_server do |config|
  config.redis = {
    url: "redis://#{redis_config['host']}:#{redis_config['port']}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: "redis://#{redis_config['host']}:#{redis_config['port']}"
  }
end
```

The above code parses `config/redis.yml` to determine the Redis host. If you're using the [Redis recipe](https://github.com/engineyard/ey-cookbooks-stable-v5/tree/next-release/custom-cookbooks/redis), it creates a `/data/<app_name>/shared/config/redis.yml` for you. 

During deployment, the file `/data/<app_name>/current/config/redis.yml` is automatically symlinked to `/data/<app_name>/shared/config/redis.yml`.

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
    
    
### Specify the Redis instance

In a clustered environment you need to tell Sidekiq where to find Redis. You can do this by enabling the Redis recipe and adding a Sidekiq initializer in `config/initializers/sidekiq.rb` with the following information:

```
Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://redis-instance", :namespace => 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://redis-instance", :namespace => 'sidekiq' }
end
``` 

Note: The use of `:namespace` requires the usage of the redis-namespace gem.

The reference to the Redis instance works because the Redis recipe adds a `redis-instance` entry in `/etc/hosts`.

More information on setting the location of your server can be found at: 
https://github.com/mperham/sidekiq/wiki/Advanced-Options 

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

### Configure multiple queues per worker

By default the recipe configures a single queue named 'Default' per every worker put in place.  The config below shows how to configure more than one queue per worker, and specify their priority as well:

```ruby
  # Queues
  sidekiq['queues'] = {
    # :queue_name => priority
    :default => 1,
    :high => 10,
    :medium => 5,
    :low => 2
  }
```

## Restarting your workers

This recipe does NOT restart your workers. The reason for this is that shipping
your application and rebuilding your instances (i.e. running chef) are not
always done at the same time. It is best to restart your Sidekiq workers
when you ship (deploy) your application code.

If you're running Sidekiq on a solo instance or on your app master, add a deploy
hook similar to:

    on_app_master do
      sudo "monit -g #{config.app}_sidekiq restart all"
    end

On the other hand, if you're running Sidekiq on a dedicated utility instance, the
deploy hook should be like:

    on_utilities("sidekiq") do
      sudo "monit -g #{config.app}_sidekiq restart all"
    end

where `sidekiq` is the name of the utility instance.

You likely want to use the after_restart hook for this. Put the code above in
`deploy/after_restart.rb`.

See our [Deploy
Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks)
documentation for more information on using deploy hooks.
