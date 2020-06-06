## custom-AddTrust

This recipe removes the expired AddTrust_External_Root.crt and updates the ca-certificates. You can read more about it on [AddTrust External CA Root expiration causing SSL certificate verification failures](https://support.cloud.engineyard.com/hc/en-us/articles/360048762994-AddTrust-External-CA-Root-expiration-causing-SSL-certificate-verification-failures)

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

  ```
  include_recipe 'custom-AddTrust'
  ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

  ```
  depends 'custom-AddTrust'
  ```

3. Copy `custom-cookbooks/packages/cookbooks/custom-AddTrust` to `cookbooks/`

  ```
  cd ~ # Change this to your preferred directory. Anywhere but inside the application

  git clone https://github.com/engineyard/ey-cookbooks-stable-v5
  cd ey-cookbooks-stable-v5
  cp custom-cookbooks/packages/cookbooks/custom-AddTrust /path/to/app/cookbooks/
  ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

