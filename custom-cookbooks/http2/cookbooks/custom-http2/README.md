# HTTP/2

This recipe enables support for HTTP/2 on `nginx` and `haproxy`.

`Haproxy` is configured to terminate SSL connection and forward HTTP/2 traffic to `nginx`. Browsers that do not support HTTP/2 are also supported by falling back to HTTP/1.1


## Prerequisites


### Nginx version >=1.9.5

As of October 2017, defaul `nginx` version under V5 stack is `1.8.1-r1` which is not HTTP/2 compatible. You can use an [overlay recipe](https://github.com/engineyard/ey-cookbooks-stable-v5/wiki/Customizing-Your-Environment-Using-Overlay-Chef-Recipes#nginx-version) to install `nginx 1.12.1` which is HTTP/2 enabled.

### SSL certicate

An SSL certificate is required. Instructions on how to obtain and install an SSL certificate can be found [here](https://support.cloud.engineyard.com/hc/en-us/articles/205407488-Obtain-and-Install-SSL-Certificates-for-Applications)

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `nginx` and `haproxy` recipes they are included by default but HTTP/2 protocol is disabled. To enable HTTP/2 you should copy this recipe `custom-http2`. You should not copy the actual `nginx` and `haproxy` recipes. These are managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-http2'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-http2'
      ```

3. Copy `custom-cookbooks/http2/cookbooks/custom-http2 ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/http2/cookbooks/custom-http2 /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

