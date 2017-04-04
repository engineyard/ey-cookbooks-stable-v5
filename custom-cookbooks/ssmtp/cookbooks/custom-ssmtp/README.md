# ssmtp

This recipe deletes the content of `/etc/ssmtp` and symlinks `/etc/ssmtp` to `/data/ssmtp` so that mail server configs are preserved when instances are terminated.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.


1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-ssmtp'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-ssmtp'
      ```

3. Copy `custom-cookbooks/ssmtp/cookbooks/custom-ssmtp ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/ssmtp/cookbooks/custom-ssmtp /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

## Customizations

To modify what gets installed as `/etc/ssmtp/ssmtp.conf` on the instances, edit the file `files/default/ssmtp.conf` inside this recipe. 