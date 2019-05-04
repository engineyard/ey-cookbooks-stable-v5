# Custom HAProxy SSLs

This recipe allows for the addition of certificates to HAProxy for SSL termination. By default the Engine Yard platform supports one SSL per environment, or one SSL per application if requested via Support. HAProxy is capable of supporting multiple certificates and automatically matching requests to the correct SSL.

## Usage

* Certificates are sourced from the Environment Variables. To create new Environmental Variables use the link in the More Options section of the Environment page in the Dashboard.
* The _Name_ of the Variable must include "HAPROXY_CERT", e.g. DOMAIN.COM_HAPROXY_CERT
* The _Value_ of the Variable must be the certificate in _pem_ format, this being the full certificate including intermediate/chain and private key, in the order: SSL Certificate -> SSL Intermediate/Chain -> Private Key
* The following instructions assume you already have a local `cookbooks` folder for your custom recipe usage
* Due to the default functionality of our usual `haproxy` recipe, this recipe relies on overlays of that recipe in order to modify its detection of certificates
* Copy the full `haproxy` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory. This will cause just these specific files to be sourced from your uploaded cookbooks and thus replace the standard files
* Copy the full `custom-haproxy-ssls` from this recipe's `cookbooks` directory to your own `cookbooks` directory
* Copy the full `lb` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory. This is required in order to excute this SSL recipe at the correct time, before the generation of the HAProxy configuration
* As above, this recipe is executed from the `lb` recipe *and not the ey-custom recipe* as usual, therefore you may wish to add a commented entry to your `after-main.rb` to remind you of this
