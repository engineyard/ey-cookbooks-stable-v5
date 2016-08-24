## DESCRIPTION

This is a wrapper cookbook for the [Solr cookbook](../solr). This is designed to help you customize how Solr is setup on your environment without having to modify the Solr recipe. If you find you're unable to modify the way Solr runs just by modifying this recipe, please open a Github issue.

<a name="usage"></a>
## USAGE

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
* (If enabled) create `/data/app_name/shared/config/sunspot.yml` populated with the IP address of the solr instance
* Create a solr core named `default`

The solr server runs on port 8983.

To access the Solr logs: `/var/log/engineyard/solr`

The Solr cookbook does not support multiple instances of Solr, or configuration of the Schema File or anything special like that.  It just starts it, and controls it in monit.

The Solr cookbook is designed for Java 8 and Solr 6 on the V5 stack. It _might_ be possible to run Solr 5, but that version hasn't been tested.

### Additional Notes For Sunspot Users

The Solr cookbook has been updated to support the latest version of Sunspot, 2.2.5.

Running `bundle exec rake sunspot:reindex` on an empty index fails. After installing, seed the index first by updating some data from the Rails console. 

## CREDITS

Radamanthus Batnag (update to Solr 6 and add Sunspot 2.2.5 support)

Original V4 Solr recipe:

* Scott M. Likens (damm)
* Brian Bommarito http://github.com/bommaritobrianmatthew (For his Sunspot recipe)
* Naftali Marcus

