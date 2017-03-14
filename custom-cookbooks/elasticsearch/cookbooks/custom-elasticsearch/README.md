# Elasticsearch

This recipe installs Elasticsearch 2.4.0 and requires Java 7 or later.


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
  "name" : "Bloodlust",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "2.4.0",
    "build_hash" : "ce9f0c7394dee074091dd1bc4e9469251181fc55",
    "build_timestamp" : "2016-08-29T09:14:17Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.2"
  },
  "tagline" : "You Know, for Search"
}
```

## Customizations

All customizations go to `cookbooks/custom-elasticsearch/attributes/default.rb`.

### Choose the instances that run the recipe

By default, the elasticsearch recipe runs on utility instances with a name that starts with `elasticsearch_`. You can change this by modifying `attributes/default.rb`.

#### A. Run Elasticsearch on utility instances

* Name the Elasticsearch instances elasticsearch\_0, elasticsearch\_1, etc.

* Uncomment this line:

```
elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch_') )
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
#elasticsearch['is_elasticsearch_instance'] = ( node['dna']['instance_role'] == 'util' && node['dna']['name'].include?('elasticsearch_') )
```

## Upgrading

If you have a small index and can easily rebuild it, the simplest way to upgrade from a previous version is to completely delete `/data/elasticsearch` and then re-run the recipe with the newer version. To do an in-place upgrade while keeping the index, please consult the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-upgrade.html).

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
