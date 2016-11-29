#
# Cookbook Name:: solr
#

include_recipe 'solr::install'
include_recipe 'solr::configure_solr_yml'
include_recipe 'solr::configure_sunspot_yml'
