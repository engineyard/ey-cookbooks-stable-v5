# Logentries

This recipe installs Logentries on Engine Yard Cloud. It sets the default Python to 2.7 - we've issues with Python 3.4.


## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `le` recipe but it is not included by default. To use the `le` recipe, you should copy this recipe `custom-le`. You should not copy the actual `le ` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      include_recipe 'custom-le'

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      depends 'custom-le'

3. Copy `custom-cookbooks/le/cookbooks/custom-le ` to `cookbooks/`

      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/le/cookbooks/custom-le /path/to/app/cookbooks/

4. Download the ey-core gem on your local machine and upload the recipes

      gem install ey-core
      ey-core recipes upload --environment <nameofenvironment>

## Customizations

All customizations go to `cookbooks/custom-le/attributes/default.rb`.

### Specify the API Key

Edit this line:

```
default['le']['le_api_key'] = 'YOUR_API_KEY_HERE'
```

