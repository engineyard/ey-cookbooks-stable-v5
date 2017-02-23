# Custom Sphinx

The thinking_sphinx_3 recipe installs sphinx, creates a monit config file, and creates thinking_sphinx.yml.

You need to add the thinking-sphinx and mysql2 gems. You need mysql2 even if you're using postgres as your database.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `thinking_sphinx_3` recipe but it does not run by default. To run the `thinking_sphinx_3` recipe, you should copy this recipe `custom-thinking_sphinx_3`. You should not copy the actual `thinking_sphinx_3` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```ruby
      include_recipe 'custom-thinking_sphinx_3'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```ruby
      depends 'custom-thinking_sphinx_3'
      ```

    If you do not have `cookbooks/ey-custom` on your app repository, you can copy `custom-cookbooks/thinking_sphinx_3/cookbooks/ey-custom` from the next step to `/path/to/app/cookbooks`.

3. Copy `custom-cookbooks/thinking_sphinx_3/cookbooks/custom-thinking_sphinx_3` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/thinking_sphinx_3/cookbooks/custom-thinking_sphinx_3 /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

      ```
      gem install ey-core
      ey-core recipes upload --environment <nameofenvironment> --path <pathtocookbooksfolder> --apply
      ```

5. Add a deploy hook to your application. Create the `deploy/` directory if it doesn't exist.

      ```ruby
      # deploy/after_symlink.rb
      on_utilities('sphinx') do
        run "[[ -d #{config.shared_path}/sphinx ]] && ln -nfs #{config.shared_path}/sphinx #{config.current_path}/db/sphinx"
        run "cd #{config.current_path} && RAILS_ENV=#{config.environment} bundle exec rake ts:configure"
      end
      ```

    See our [Deploy Hook](https://engineyard.zendesk.com/entries/21016568-use-deploy-hooks) documentation for more information on using deploy hooks.

## Customizations

All customizations go to `cookbooks/custom-thinking_sphinx_3/attributes/default.rb`.

### Choose the instance that run the recipe

By default, the thinking_sphinx_3 recipe runs on a utility instance named `sphinx`. You can change this by setting `default['sphinx']['utility_name'] `. For advanced users, you can run sphinx on non-util instances by using `node['dna']['instance_role']`. 

```ruby
# this is the default
default['sphinx']['utility_name'] = 'sphinx'

# run sphinx on a utility instance named search
default['sphinx']['utility_name'] = 'search'

# run the recipe on a solo instance
# you need to add 2 lines
default['sphinx']['utility_name'] = 'this_will_not_match_a_util'
default['sphinx']['is_thinking_sphinx_instance'] = (node['dna']['instance_role'] == 'solo')
```

### Choose the applications that run sphinx

By default, we create sphinx.yml and monitrc for all applications. This works if you only have one application on the environment. Running multiple sphinx processes is not supported. If you have more than one application on the environment, you must choose one application.

```ruby
# this is the default
# get all applications
default['sphinx']['applications'] = node['dna']['applications'].map{|app_name, data| app_name}

# specify the application name 
default['sphinx']['applications'] = ['todo']
```

### Choose the sphinx version

```ruby
# this is the default
default['sphinx']['version'] = '2.1.9'

# specify a new version
# run eix -C app-misc sphinx on the instance to get possible values
default['sphinx']['version'] = '2.2.10'
```

### Choose the frequency of the indexer cron job

You need to reindex regularly. The recipe adds a cron job for the `indexer` command.

```ruby
# the default is reindex every 15 minutes
default['sphinx']['frequency'] = 15

# change it to 60 minutes
default['sphinx']['frequency'] = 60
```

### Run sphinx on every app instance

By default, sphinx runs on one utility instance only. This makes it a single point of failure. You can run sphinx on every app instance and let each app instance connect to localhost.

The advantage is if an app instance goes down, search will still work. The disadvantages are 1) you have to reindex on each app instance, which can overload your database, 2) your utility instances won't have access to search, and 3) you have to manage multiple sphinx processes which all do the same thing.

You have to add all 3 lines

```ruby
default['sphinx']['utility_name'] = 'this_will_not_match_a_util'
default['sphinx']['is_thinking_sphinx_instance'] = ['app_master', 'app'].include?(node['dna']['instance_role'])
default['sphinx']['host'] = '127.0.0.1'
```
