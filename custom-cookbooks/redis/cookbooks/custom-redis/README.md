# Redis

This recipe installs version Redis 2.8 or later using either the package from the Engine Yard portage treee (recommended) or the Redis installer from redis.io.


## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `redis` recipe but it is not included by default. To use the `redis` recipe, you should copy this recipe `custom-redis`. You should not copy the actual `redis ` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-redis'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-redis'
      ```

3. Copy `custom-cookbooks/redis/cookbooks/custom-redis ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/redis/cookbooks/custom-redis /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

## Customizations

All customizations go to `cookbooks/custom-redis/attributes/default.rb`.

### Choose the instance that runs the recipe

By default, the redis recipe runs on a utility instance named "redis". You can change this by modifying `attributes/default.rb`.

#### A. Run Redis on a utility instance with a custom name

* Ensure that these lines are not commented out:

	```
	redis['utility_name'] = 'redis'
 	redis_instances << redis['utility_name']
 	redis['is_redis_instance'] = (
  	  node['dna']['instance_role'] == 'util' &&
   	  redis_instances.include?(node['dna']['name'])
 	)
	```

* Specify the redis instance name. If the instance is not yet running, boot an instance with that name.

* Make sure this line is commented out:

	```
	redis['is_redis_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )
	```

#### B. Run Redis on a solo environment

Note that this is not recommended for production environments. Running Redis on a solo environment can potentially increase swap usage and slow down the instance.

* Uncomment this line:

	```
	#redis['is_redis_instance'] = (node['dna']['instance_role'] == 'solo')
	```

* Make sure these lines are commented out:

	```
	redis['utility_name'] = 'redis'
 	redis_instances << redis['utility_name']
 	redis['is_redis_instance'] = (
   		node['dna']['instance_role'] == 'util' &&
   		redis_instances.include?(node['dna']['name'])
 	)
	```
	
#### C. Run Redis on the same instance as Sidekiq

On staging environments, or in a production environment with a low job volume, you might want to run Sidekiq and Redis within the same instance.

* Ensure that these lines are not commented out:

	```
	redis['utility_name'] = 'redis'
 	redis_instances << redis['utility_name']
 	redis['is_redis_instance'] = (
  	  node['dna']['instance_role'] == 'util' &&
   	  redis_instances.include?(node['dna']['name'])
 	)
	```

* Specify the same instance name for Redis and Sidekiq. 

  On `custom-redis/attributes/default.rb`:
  
  ```
  redis['utility_name'] = 'sidekiq'
  ```
  
  On `custom-sidekiq/attributes/default.rb`:
  
  ```
  default['sidekiq']['is_sidekiq_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'sidekiq')
  ```

* If the instance is not yet running, boot an instance with that name.

* Make sure this line is commented out:

	```
	redis['is_redis_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )
	```
	
#### D. Run Redis on the same instance as Resque

On staging environments, or in a production environment with a low job volume, you might want to run Resque and Redis within the same instance.

* Ensure that these lines are not commented out:

	```
	redis['utility_name'] = 'redis'
 	redis_instances << redis['utility_name']
 	redis['is_redis_instance'] = (
  	  node['dna']['instance_role'] == 'util' &&
   	  redis_instances.include?(node['dna']['name'])
 	)
	```

* Specify the same instance name for Redis and Resque. 

  On `custom-redis/attributes/default.rb`:
  
  ```
  redis['utility_name'] = 'resque'
  ```
  
  On `custom-resque/attributes/default.rb`:
  
  ```
  default['resque']['is_resque_instance'] = (node['dna']['instance_role'] == 'util' && node['dna']['name'] == 'resque')
  ```

* If the instance is not yet running, boot an instance with that name.

* Make sure this line is commented out:

	```
	redis['is_redis_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )
	
### Master-Slave Replication

Master-Slave replication can be used for redundancy, or to minimize the downtime when upgrading the Redis instance.

#### Setup

To setup master-slave replication, follow these steps:

1. Uncomment these lines:

	```
	#redis['slave_name'] = 'redis_slave'
	#redis_instances << redis['slave_name']
	```

2. Boot a utility instance named 'redis_slave'.

3. Upload and run chef.

4. After the chef run, the new utility instance 'redis_slave' will be replicating from the redis instance.

#### Promotion

As of now, the dashboard does not provide an automated promotion for the Redis slave instance. To promote the slave instance, follow these steps:

1. Stop all processes connected to Redis. You can do this by putting the application in maintenance mode and stopping all background workers.
2. Rename the 'redis_slave' instance to 'redis'
3. Terminate the old 'redis' instance
4. Click Apply on the environment
5. Restart the application and all processes that use Redis (e.g. background workers like Resque and Sidekiq). If you have deploy hooks for restarting background workers in place, then performing a deploy should do the restart for you.
6. From the 'redis' instance, run `redis-cli -h localhost slaveof no one`

## Upgrading

If you're upgrading from a previous version of Redis that was setup using this recipe, set `redis['force_upgrade']` to `true`. This will preserve the old redis database, install the newer Redis version, and run the new Redis version with the old database. Prior to running the upgrade recipe, stop updates to the Redis database by putting the application in maintenance mode and stopping all background workers.

To be on the safe side, this recipe does not restart Redis as that can cause downtime. After an upgrade, the newer version of Redis will be installed but the old version will still be running. You should ssh to the Redis instance and run `sudo monit restart redis` to run the newer version.

Redis doesn't guarantee backwards compatibility across versions. In general newer versions can load an RDB dump from an older version, but not vice-versa. To be on the safe side, we recommend testing the upgrade on a staging environment first.

## Dependencies

You need to install the appropriate Redis client library for your application. See https://redis.io/clients

## Test Cases

This custom chef recipe has been verified using these test cases:

```
A. Run Redis 3.2.6 for the first time on a solo instance
  A.1. Redis should be running on the solo instance
  A.2. `/etc/hosts` should have a redis-instance entry that points to the solo instance private IP address
  A.3. `/data/appname/shared/config/redis.yml` should have a host entry that points to the solo instance private hostname
B. Run Redis 3.2.6 for the first time on a utility instance named 'redis'
  B.1. Redis should be running on the redis instance
  B.2. `/etc/hosts` should have a redis-instance entry that points to the redis instance private IP address
  B.3. `/data/appname/shared/config/redis.yml` should have a host entry that points to the redis instance private hostname (ip-10-x-x-x.ec2.internal)
C. Run Redis 3.2.6 for the first time on a utility instance named 'sidekiq
  C.1. Redis should be running on the sidekiq instance
  C.2. `/etc/hosts` should have a redis-instance entry that points to the sidekiq instance private IP address
  C.3. `/data/appname/shared/config/redis.yml` should have a host entry that points to the sidekiq instance private hostname (ip-10-x-x-x.ec2.internal)
D. Upgrade a solo instance from Redis 3.2.6 to Redis 4.0-rc2
  D.1. Redis 4.0-rc2 should be running on the solo instance
  D.2. `/etc/hosts` should have a redis-instance entry that points to the solo instance private IP address
  D.3. `/data/appname/shared/config/redis.yml` should have a host entry that points to the solo instance private hostname (ip-10-x-x-x.ec2.internal)
  D.4. After restarting Redis, data that was stored on the Redis 2.8.21 database should be available on the Redis 4.0-rc2 database
E. Upgrade a cluster from Redis 3.2.6 to Redis 4.0-rc2
  E.1. Redis 4.0.rc2 should be running on the redis instance
  E.2. `/etc/hosts` should have a redis-instance entry that points to the redis instance private IP address
  E.3. `/data/appname/shared/config/redis.yml` should have a host entry that points to the redis instance private hostname (ip-10-x-x-x.ec2.internal)
  E.4. After restarting Redis, data that was stored on the Redis 3.2.6 database should be available on the Redis 4.0-rc2 database
F. Verify Replication
  F.1. Setup Redis on a cluster with 2 utility instances, 'redis' and 'redis_slave'. Setup master-slave replication between 'redis' and 'redis-slave'
  F.2. Verify that the redis role of the redis instance is master
  F.3. Verify that the redis role of the redis_slave instance is slave
  F.4. Save data on the redis and verify that it's replicated on redis_slave. 
  F.5. Follow the [promotion steps](https://github.com/engineyard/ey-cookbooks-stable-v5/tree/next-release/custom-cookbooks/redis/cookbooks/custom-redis#promotion). After the promotion, verify that the role of the redis instance (renamed from redis_slave) is master. 
```
