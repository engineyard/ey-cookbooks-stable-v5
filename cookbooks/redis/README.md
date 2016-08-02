## Optional Cookbook for Engine Yard Cloud

# Redis

[Redis][1] Redis is an open source, advanced key-value store. It is often referred to as a data structure server since keys can contain [strings][7], [hashes][6], [lists][5], [sets][4] and [sorted sets][3].  Learn More at the [introduction][7].

## Overview

This cookbook provides a method to host a dedicated redis instance.  This recipe should *NOT* be used on your Database instance as it is not designed for that instance.  Additionally it will not change nor modify your database instance in anyway what so ever.

## Installation

Since this is an optional recipe, it should be installed by simply including it via a `depends` in your `ey-custom/metadata.rb` file and an `include_recipe` in the appropriate hook file. For more details on optional recipes see the [redis example]. (Yes, how convenient that the example is for the exact recipe you wanted)

This recipe will only activate on instances containing the name `redis`.

## Design

* 1+ utility instances
* over-commit is enabled by default to ensure the least amount of problems saving your database.
* 64-bit is required for storing over 2gigabytes worth of keys.
* /etc/hosts mapping for `redis-instance` so that a hard config can be used to connect

## Backups

This cookbook does not automate nor facilitate any backup method currently.  By default there is a snapshot enabled for your environment and that should provide a viable backup to recover from.  If you have any backup concerns open a ticket with our [Support Team][9].


## Changing Defaults

A large portion of the defaults of this recipe have been moved to a attribute file; if you need to change how often you save; review the attribute file and modify.

## Choosing a different Redis version

This recipe installs Redis 3.2.0 by default.

To install a different version of Redis, override the `:version` attribute. You can do this with a new file in `cooobooks/redis/attributes` such as `overrides.rb` which sets the attribute like so:

  node['redis']['version'] = "1.0"

## Notes

1. Please be aware these are default config files and will likely need to be updated :)
2. This recipe will put in place a `redis.yml` on `/data/{app_name}/shared/config/`.

## How to get Support

* irc://irc.freenode.net/#redis
* This Github repository.
* This Cookbook provides a technology that is listed in the Engine Yard [Technology Stack][2]

[1]: http://redis.io/
[2]: http://www.engineyard.com/products/technology/stack
[3]: http://redis.io/topics/data-types#sorted-sets
[4]: http://redis.io/topics/data-types#sets
[5]: http://redis.io/topics/data-types#lists
[6]: http://redis.io/topics/data-types#hashes
[7]: http://redis.io/topics/data-types#strings
[8]: http://redis.io/topics/introduction
[9]: https://support.cloud.engineyard.com
