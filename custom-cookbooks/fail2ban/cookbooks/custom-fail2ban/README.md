# fail2ban

This recipe installs fail2ban using the package from the Engine Yard portage tree.


## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `fail2ban` recipe but it is not included by default. To use the `fail2ban ` recipe, you should copy this recipe `custom-fail2ban `. You should not copy the actual `fail2ban ` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/fail2ban/after-main.rb` and add

      ```
      include_recipe 'custom-fail2ban'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-fail2ban'
      ```

3. Copy `custom-cookbooks/fail2ban/cookbooks/custom-fail2ban ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/fail2ban/cookbooks/custom-fail2ban /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment <nameofenvironment> --path <pathtocookbooksfolder>
  ```

## Customizations

All customizations go to `cookbooks/custom-fail2ban/attributes/default.rb`.

### Specify the fail2ban version

```
default['fail2ban']['version'] = '0.9.4'
```

The available versions under the v5 stack are:

- 0.8.14
- 0.9.3-r1
- 0.9.4

### Specify the log level

```
default['fail2ban']['loglevel'] = 'DEBUG'
```

The log level options are:

```
1 = ERROR
2 = WARN
3 = INFO
4 = DEBUG
```

### Configure the jails

Configure the `default['fail2ban']['jails']` hash. Please see the comments in `custom-fail2ban/attributes/default.rb` for more information.
