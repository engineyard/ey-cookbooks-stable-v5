# Custom CA Certificates

This recipe allows for the addition of missing 3rd party intermediate/chain certificates as custom CA certificates, thus avoiding certificate verification failures.

## Usage

* Certificates are sourced from the Environment Variables. To create new Environmental Variables use the link in the More Options section of the Environment page in the Dashboard.
* The _Name_ of the Variable must being "EY_CA_CERT", e.g. EY_CA_CERT_SSL_com_DV_CA. The name must contain only letters, numbers or underscore symbols.
  * If running stack release [stable-v5-3.0.62](https://support.cloud.engineyard.com/hc/en-us/articles/360034331653-Engine-Yard-Release-Notes-for-August-13th-2019-Stack-V5-) or above any Environment Variables prepended with EY_ will not be added to the config/env.cloud file and thus not loaded by the application, improving security
* Required intermediate/chain certificates can be obtained by checking the failing URL at [https://whatsmychaincert.com](https://whatsmychaincert.com). The downloaded certificate should then be opened in a text editor and the full contents copied into the Environmental Variable _Value_.
* The following instructions assume you already have a local `cookbooks` folder for your custom recipe usage:
* Copy the full `custom-ca-certs` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory.
* Add `include_recipe 'custom-ca-certs'` to your `ey-custom/recipes/after-main.rb`.
* Add `depends 'custom-ca-certs'` to your `ey-custom/metadata.rb`.
* Upload your recipes and run an _Apply_.
