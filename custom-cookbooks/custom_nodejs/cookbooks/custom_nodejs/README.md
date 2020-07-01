# Custom Node.js

This cookbook can serve as a good starting point for upgrading Node.js in your instances.
Specifically, it gives you the tools in order to install versions of nodejs that are not present in the portage tree.

** Please Note ** This recipe will setup the selected version of Node.js (the version specified in attributes) in all instances by default. If you need custom_nodejs to run only in app/util, you will need to modify the recipe. Also, since this recipe is practically installing node versions not officially supported by portage, integration is not guaranteed.  

## Installation

* The following instructions assume you already have a local `cookbooks` directory for your custom recipe usage, if you do not the firstly create a `cookbooks` directory.
* Copy the full `custom_nodejs` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory.
* Copy the full `node` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory. This will overlay the `node` recipe's `common.rb` and prevent the Node.js version being reverted.
* If you already have a `cookbooks/ey-custom` directory, add `include_recipe 'custom_nodejs'` to your `ey-custom/recipes/after-main.rb`.
* If you already have a `cookbooks/ey-custom` directory, add `depends 'custom_nodejs'` to your `ey-custom/metadata.rb`.
* If you do not already have a `cookbooks/ey-custom` directory, copy the full `ey-custom` directory from this recipe's `cookbooks` directory to your own `cookbooks` directory.
* Upload your recipes and run an _Apply_.

## Customizations

* The version of Node.js to be install can be set in `attributes/default.rb`. Please avoid installing the same versions already existing in portage (check via `eix nodejs`). You can check the available versions [here](https://nodejs.org/en/download/releases/). 
* To revert the custom version of Node.js to the one configured on your environment's _Edit Environment_ page you must both remove/disable this recipe _and remove the `node` directory to remove the `common.rb` overlay.
