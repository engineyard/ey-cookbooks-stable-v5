# env_vars

This recipe uploads an env.custom file that can be used to configure environment variables for applications running on Engine Yard Cloud. Engine Yard Cloud scripts for Passenger, Puma and Unicorn source this env.custom file to set the environment variables.


## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `env_vars` recipe but it is not included by default. To use the `env_vars` recipe, you should copy this recipe `custom-env_vars`. You should not copy the actual `env_vars ` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/env_vars/after-main.rb` and add

      ```
      include_recipe 'custom-env_vars'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-env_vars'
      ```

3. Copy `custom-cookbooks/env_vars/cookbooks/custom-env_vars ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/fail2ban/cookbooks/custom-env_vars /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment <nameofenvironment> --path <pathtocookbooksfolder>
  ```

## Customizations

All customizations go to `cookbooks/custom-env_vars/attributes/default.rb`.

### Restart the application during the chef run

Every time you update `env.custom`, you need to restart the application. A Unicorn or Puma hot restart will not do; you need to start a new master process that has sourced the updated `env.custom` file.

To restart the application, you can cycle through the application instances and run `/engineyard/bin/app_<application_name> restart` on each one.
