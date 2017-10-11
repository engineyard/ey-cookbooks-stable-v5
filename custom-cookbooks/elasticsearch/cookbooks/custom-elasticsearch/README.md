# Elasticsearch

This recipe installs Elasticsearch 2.x/5.x. Elasticsearch 2.x requires Java 7 or later, Elasticsearch 5.x requires Java 8.

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

Our main recipes have the `elasticsearch` recipe but it is not included by default. To use the `elasticsearch` recipe, you should copy this recipe `custom-elasticsearch`. You should not copy the actual `elasticsearch ` recipe. That is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-elasticsearch'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-elasticsearch'
      ```

3. Copy `custom-cookbooks/elasticsearch/cookbooks/custom-elasticsearch ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v5
      cd ey-cookbooks-stable-v5
      cp custom-cookbooks/elasticsearch/cookbooks/custom-elasticsearch /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```

5. After running chef, ssh to an elasticsearch instance to verify that it's running.

Run:

```
curl localhost:9200
```

Results should be simlar to:

```
{
  "name" : "PcF22DZ",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "4QH3ZKEFTo6E0NP6G5Y9Jw",
  "version" : {
    "number" : "5.4.0",
    "build_hash" : "780f8c4",
    "build_date" : "2017-04-28T17:43:27.229Z",
    "build_snapshot" : false,
    "lucene_version" : "6.5.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Customizations

All customizations go to `cookbooks/custom-elasticsearch/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the elasticsearch recipe runs on utility instances with a name includes the word `elasticsearch`. You can change this by modifying `attributes/default.rb`.

#### A. Run Elasticsearch on utility instances

* Name the Elasticsearch instances elasticsearch\_0, elasticsearch\_1, etc.

* Uncomment this line:

```
elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch') )
```

* Make sure this line is commented out:

```
elasticsearch['is_elasticsearch_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )
```

* Set `configure_cluster` to true:

```
elasticsearch['configure_cluster'] = true
```

#### B. Run Elasticsearch on app_master or on a solo environment

This is not recommended for production environments.

* Uncomment this line:

```
elasticsearch['is_elasticsearch_instance'] = ( ['solo', 'app_master'].include?(node['dna']['instance_role']) )
```

* Make sure this line is commented out:

```
#elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch') )
```

### Specify the Elasticsearch version

Set `elasticsearch['version']` in `attributes/default.rb`, and comment out or delete references to other versions.

```
  elasticsearch['version'] = '5.5.0'
  #elasticsearch['version'] = '2.4.4'
```

You need to do the same for `elasticsearch['checksum']` and `elasticsearch['download_url']`.

To calculate the SHA256 checksum, download the zip file and then run:

- `sha256sum <zipfile>` (Linux)
- `shasum -a 256 <zipfile>` (OSX)

```
  elasticsearch['checksum'] = '02d9b16334ca97eaaab308bb65743ba18249295d4414f6967c2daf13663cf01d'   # checksum for 5.5.0
  #elasticsearch['checksum'] = 'bee3ca3d5b2103e09b18e1791d1cc504388b992cc4ebf74869568db13c3d4372'  # checksum for 2.4.4
```

```
  # Use this URL for the 5.x.x versions
  elasticsearch['download_url'] = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-#{elasticsearch['version']}.zip"
  # Use this URL for the 2.4.x versions
  #elasticsearch['download_url'] = "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/#{elasticsearch['version']}/elasticsearch-#{elasticsearch['version']}.zip"
```

### Configure JVM Options

_NOTE: As of this writing, this recipe allows you to customize the JVM options only if you're running Elasticsearch 5.x. The chef recipe sets the JVM options through the `jvm.options` file. The earlier 2.x versions do not use this file to configure the JVM options._

You can configure the JVM minimum and maximum heap size, and the stack size setting by editing the jvm_options key in `attributes/default.rb`:

```
elasticsearch['jvm_options'] = {
  :Xms => '2g',
  :Xmx => '2g',
  :Xss => '1m'
}
```

For guidelines on how to calculate the optimal JVM memory settings, see [https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html](https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html).

You can also hard-code other JVM options by editing `custom-elasticsearch/templates/default/jvm.options.erb`.

After updating the JVM options, you need to restart Elasticsearch by running `sudo monit restart elasticsearch` on all Elasticsearch instances. The recipe does not automatically restart Elasticsearch as that can cause downtime.

## Upgrading

If you have a small index and can easily rebuild it, the simplest way to upgrade from a previous version is to completely delete `/data/elasticsearch` and then re-run the recipe with the newer version. To do an in-place upgrade while keeping the index, please consult the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html).

If you’re upgrading from 2.x to 5.x, the 5.x versions require higher limits in `/etc/security/limits.conf`. The latest version of the recipe sets up the higher limits on `/etc/security/limits.conf`, but an instance reboot is needed for the change to take effect. Terminating the old ES 2.x instance and booting a new one may be the simpler path. 

## Dependencies

  * Your application should use gems(s) such as [tire][4],[rubberband][3],[elastic_searchable][5].

Plugins
--------

Rudamentary plugin support is there in a definition.  You will need to update the template for configuration options for said plugin; if you wish to improve this functionality please submit a pull request.

custom-cookbooks:

``es_plugin "cloud-aws" do``
``action :install``
``end``

``es_plugin "transport-memcached" do``
``action :remove``
``end``


Caveats
--------

plugin support is still not complete/automated.  CouchDB and Memcached plugins may be worth investigating, pull requests to improve this.

Backups
--------

Non-automated, regular snapshot should work.  If you have a large cluster this may complicate things, please consult the [elasticsearch][2] documentation regarding that.


Warranty
--------

This cookbook is provided as is, there is no offer of support for this
recipe by Engine Yard in any capacity.  If you find bugs, please open an
issue and submit a pull request.

[1]: http://lucene.apache.org/
[2]: http://www.elasticsearch.org/
[3]: https://github.com/grantr/rubberband
[4]: https://github.com/karmi/tire
[5]: https://github.com/wireframe/elastic_searchable/
