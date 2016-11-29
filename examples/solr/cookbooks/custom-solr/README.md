## Custom Solr

This is a wrapper cookbook for Solr. This is designed to help you customize how Solr is setup on your environment without having to modify the Solr recipe. If you find you're unable to modify the way Solr runs just by modifying this recipe, please open a Github issue.

<a name="#installation"></a>
## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the solr recipe but it is not included by default. To use the solr recipe, you should copy this recipe, `custom-solr`. You should not copy the actual solr recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

  ```
  include_recipe 'custom-solr'
  ```
   
2. Edit `cookbooks/ey-custom/metadata.rb` and add

  ```
  depends 'custom-solr'
  ```

3. Copy `examples/solr/cookbooks/custom-solr` to `cookbooks/`

  ```
  cd ~ # Change this to your preferred directory. Anywhere but inside the application

  git clone https://github.com/engineyard/ey-cookbooks-stable-v5
  cd ey-cookbooks-stable-v5
  cp examples/delayed_job4/cookbooks/custom-delayed_job4 /path/to/app/cookbooks/
  ```

If you do not have `cookbooks/ey-custom` on your app repository, you can copy `examples/solr/cookbooks/ey-custom` to `/path/to/app/cookbooks`.

<a name="usage"></a>
## Usage

Enable the recipe:

1. add `depends 'custom-solr' to ey-custom/metadata.rb`
1. add `include_recipe 'custom-solr'` to `ey-custom/recipes/after-main.rb`

To stop the solr server use the following on the SSH console: `sudo monit stop solr`

To start the solr server use the following on the SSH console: `sudo monit start solr`

<a name="ramblings"></a>
## RAMBLINGS

The Solr cookbook does the following:

* Setup Solr in /data/solr in a solo environment. In a cluster environment, this sets up Solr in /data/solr of a util instance named "solr"
* Create `/engineyard/bin/solr` for starting and stopping solr
* Create a monitrc file for solr
* Create `/data/app_name/shared/config/solr.yml` populated with the IP address of the solr instance
* Create `/data/app_name/shared/config/sunspot.yml` populated with the IP address of the solr instance
* Create a solr core named `default`

The solr server listens on port 8983. The port can be modified by setting `node['solr']['port']` in the attributes file.

To access the Solr logs: `/var/log/engineyard/solr`

The Solr cookbook does not support multiple instances of Solr, or configuration of the Schema File or anything special like that.  It just starts it, and controls it in monit.

The Solr cookbook is designed for Java 8 and Solr 6 on the V5 stack. It _might_ be possible to run Solr 5, but that version hasn't been tested.

### Additional Notes For Sunspot Users

The Solr cookbook has been updated to support the latest version of Sunspot, 2.2.5.

Running `bundle exec rake sunspot:reindex` on an empty index fails. After installing, seed the index first by updating some data from the Rails console. 

## CREDITS

* Radamanthus Batnag (update to Solr 6 and add Sunspot 2.2.5 support)
* Allan Espinosa for reviewing the recipe

Original V4 Solr recipe:

* Scott M. Likens (damm)
* Brian Bommarito http://github.com/bommaritobrianmatthew (For his Sunspot recipe)
* Naftali Marcus

