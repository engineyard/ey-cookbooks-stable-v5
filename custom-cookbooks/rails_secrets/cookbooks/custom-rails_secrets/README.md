# rails_secrets

This recipe uploads the Rails `secrets.yml` file to `/data/application_name/shared/config/secrets.yml`.

## Installation

For most cases, we recommend that you create the cookbooks directory at the root of your application. However, if you’re using the `rails_secrets` recipe, for security purposes, you should consider putting the cookbooks on its own repository.

Our main recipes have the `rails_secrets` recipe but it is not included by default. To use the `rails_secrets` recipe, you should copy this recipe `custom-rails_secrets`. You should not copy the actual `rails_secrets` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-rails_secrets'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-rails_secrets'
      ```

3. Copy `custom-cookbooks/rails_secrets/cookbooks/custom-rails_secrets` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/rails_secrets/cookbooks/custom-rails_secrets /path/to/app/cookbooks/
      ```
4. For each application in the environment, create `/path/to/app/cookbooks/custom-rails_secrets/templates/default/secrets.yml.#{app_name}.erb`

If you do not have `cookbooks/ey-custom` on your app repository, you can copy `custom-cookbooks/rails_secrets/cookbooks/ey-custom` to `/path/to/app/cookbooks`.

## Customizations

The recipe supports multi-application environments. You need to create a `secrets.yml.#{app_name}.erb` file for each application as described in step #4 of the Installation instructions above.

The file `secrets.yml.todo.erb` has been included as an example. Feel free to remove or modify this file.
