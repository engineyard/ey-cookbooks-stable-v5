# Memcached

The memcached cookbook installs memcached and monitors it with monit. A `/data/app_name/shared/config/memcached.yml` is generated for each application on the environment.

You need to add a memcached client to your app.

## Installation

For simplicity, we recommend that you create the `cookbooks/` directory at the
root of your application. If you prefer to keep the infrastructure code separate
from application code, you can create a new repository.

Our main recipes have the `memcached_custom` cookbook but it is not included by default.
To use the `memcached_custom` cookbook, you should copy the cookbook
`custom-memcached`. You should not copy the actual `memcached_custom` recipe as
that is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

```
    include_recipe 'custom-memcached'
```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

```
    depends 'custom-memcached'
```

3. Copy `examples/memcached/cookbooks/custom-memcached` to `cookbooks/`

```
    cd ~ # Change this to your preferred directory. Anywhere but inside the
         # application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp examples/memcached/cookbooks/custom-memcached /path/to/app/cookbooks/
```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy
`examples/memcached/cookbooks/ey-custom` to `/path/to/app/cookbooks` as well.

## Customizations

All customizations go to `cookbooks/custom-memcached/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the recipe runs on a utility instance named 'memcached'. This is configured in `attributes/default.rb`. This will run the memcached daemon on the utility instance named 'memcached' and create a `/data/appname/shared/config/memcached_custom.yml` file that points to the private IP of the memcached instance.

```
  # Install memcached on a utility instance named 'memcached'
  memcached['install_type'] = 'NAMED_UTILS'
  memcached['utility_name'] = 'memcached'
```

To install memcached on all app instances, comment out the block above and set `memcached['install_type']` to 'ALL_APP_INSTANCES'. This will run the memcached daemon on all app instances and create a `/data/appname/shared/config/memcached_custom.yml` file that points to the private IPs of all the app instances. The memcache client will be responsible for sharding the data across all the instances running memcached

```
  # Install memcached on all app instances
  #memcached['install_type'] = 'ALL_APP_INSTANCES'
```


### Adjust memory usage

```
  # Amount of memory in MB to be used by memcached
  memcached['memusage'] = 1024
```

### Adjust the growth factor

```
  # Increase the growth factor.
  # Try this if you allocated more memory to memcached
  # and you're seeing lots of partially-filled slabs
  # memcached['misc_opts'] = '-f 1.5'
  # See https://blog.engineyard.com/2015/fine-tuning-memcached
```

## Restarting your application

This recipe does NOT restart your application. The reason for this is that shipping
your application and rebuilding your instances (i.e. running chef) are not
always done at the same time. It is best to restart your application
when you ship (deploy) your application code.

## Test Cases

This custom chef recipe has been verified using these test cases:

```
A. Install memcached on all app instances
  A1. memcached should be running on app_master
  A2. memcached should be running on app instances
  A3. memcached should not be running on utility or database instances
  A4. /data/app_name/shared/config/memcached_custom.yml should list all the app instances in the environment

B. Install memcached on a utility instance named 'memcached'
  B1. memcached should be running on the utility instance named memcached
  B2. memcached should not be running on app_master, app, and database instances
  B3. /data/app_name/shared/config/memcached_custom.yml should list all the utility instances named memcached in the environment
```
