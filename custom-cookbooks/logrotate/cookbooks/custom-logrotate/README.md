# Custom logrotate

This recipe simply calls the `logrotate` resource defined in the main `logrotate` recipe: [cookbooks/logrotate/definitions/logrotate.rb](../../../../cookbooks/logrotate/definitions/logrotate.rb).

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `logrotate` recipe that defines the `logrotate` resource. To use the `logrotate` resource, you can copy this recipe `custom-logrotate`. You should not copy the actual `logrotate` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

    ```
    include_recipe 'custom-logrotate'
    ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

    ```
    depends 'custom-logrotate'
    ```

3. Copy `custom-cookbooks/logrotate/cookbooks/custom-logrotate` to `cookbooks/`

    ```
    cd ~ # Change this to your preferred directory. Anywhere but inside the application

    git clone https://github.com/engineyard/ey-cookbooks-stable-v5
    cd ey-cookbooks-stable-v5
    cp custom-cookbooks/logrotate/cookbooks/custom-logrotate /path/to/app/cookbooks/
    ```

4. Download the ey-core gem on your local machine and upload the recipes

    ```
    gem install ey-core
    ey-core recipes upload --environment <nameofenvironment> --path <pathtocookbooksfolder> --apply
    ```

5. After running chef, check the new logrotate configuration in /etc/logrotate.d/.

    The content would look like:

    ```
    /path/to/logfiles/*log {
        daily
        rotate 30
        dateext
        compress

        missingok
        notifempty
        sharedscripts
        extension gz
        copytruncate
    }
    ```

## Customizations

Unlike the usual custom chef recipes, you need to modify the recipe in `cookbooks/custom-logrotate/recipes/default.rb` for customizations.

The available options are shown as comments in custom-logrotate/recipes/default.rb. For more info about those options, run `man logrotate` in the server.
