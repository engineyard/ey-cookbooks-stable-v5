## Custom Scheduled Scaling

This is a wrapper cookbook for scheduled-scaling. This is designed to help you customize how to scale up/down environment/instances without having to modify the 'scheduled_scaling' recipe. If you find you're unable to modify the way 'scheduled_scaling' runs just by modifying this recipe, please open a Github issue.

## Prerequisites ##

An environment where to run this recipe, which can't be the same one that is being stopped/started.
The name of the environment to be stopped/started.
An Elastic IP to be used on the environment.
A blueprint with the configuration the environment should have when started.
Open a ticke with EY Support to add a metadata entries at the Account level for the `CORE_API` token, with value `core_api_token`, on the environment where the scaler instance runs.  If you don't have an API token, it can be obtained from cloud.engineyard.com/cli


<a name="#installation"></a>
## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the scheduled_scaling recipe but it is not included by default. To use the recipe, you should copy this recipe, `custom-scheduled_scaling`. You should not copy the actual `scheduled_scaling` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

  ```
  include_recipe 'custom-scheduled_scaling'
  ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

  ```
  depends 'custom-scheduled_scaling'
  ```

3. Copy `custom-cookbooks/solr/cookbooks/custom-scheduled_scaling` to `cookbooks/`

  ```
  cd ~ # Change this to your preferred directory. Anywhere but inside the application

  git clone https://github.com/engineyard/ey-cookbooks-stable-v5
  cd ey-cookbooks-stable-v5
  cp custom-cookbooks/scheduled_scaling/cookbooks/custom-scheduled_scaling /path/to/app/cookbooks/
  ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

<a name="usage"></a>
## Usage

Check file `custom-scheduled_scaling/attributes/default.rb` for details.

<a name="customizations"></a>
## Customizations

All customizations go to `custom-scheduled_scaling/attributes/default.rb`.

## Credits

* Daniel Valfre (creator)
* Dennis Walters for reviewing the recipe

