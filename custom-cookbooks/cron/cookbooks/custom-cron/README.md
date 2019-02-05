# custom-cron

This is a wrapper cookbook around Engine Yard's cron cookbook.  It automates the
addition of cron jobs  for the application user (`deploy`)on the 
instance name or type specified for each cron job. All cron jobs are specified in the
attributes file of the cron cookbook.

## Limitations
This cookbook will not install cron jobs for the root user, it must be modified
if this is required.  Cron jobs are installed for the default application user,
typically called `deploy`.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root
of your application. If you prefer to keep the infrastructure code separate from
application code, you can create a new repository.

Our main cookbook have the `cron` cookbook but it is not included by default.
To use the `cron` cookbook, you should copy this cookbook, `custom-cron`.
You should not copy the actual `cron` recipe. That is managed by Engine
Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

  ```
  include_recipe 'custom-cron'
  ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

  ```
  depends 'custom-cron'
  ```

3. Copy `custom-cookbooks/packages/cookbooks/custom-cron` to `cookbooks/`

  ```
  cd ~ # Change this to your preferred directory. Anywhere but inside the application

  git clone https://github.com/engineyard/ey-cookbooks-stable-v5
  cd ey-cookbooks-stable-v5
  cp custom-cookbooks/packages/cookbooks/custom-packages /path/to/app/cookbooks/
  ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfilder> --apply
  ```

## Customizations

All customizations go to `cookbooks/custom-cron/attributes/default.rb`.

Add your cron jobs as an array of hashes in `default[:custom_crons]` You must
specify a name, time, command and instance name or instance type. The following arguments are valid: `app`,`app_master`, `db`, `util`, `all`, or "instance_name".  The time value must be the
full string containing minute, hour, day, month and weekday separated by spaces
(eg: '* * * * *').

```
default[:custom_crons] = [
   {:name => "Install on myRedisInstance only", :time => "10 * * * *",
    :command => "echo 'test1'", :instance_name => "myRedisInstance"
  },
  {:name => "Install on all instances", :time => "10 1 * * *",
   :command => "echo 'test2'", :instance_name => "all"}
]
```
