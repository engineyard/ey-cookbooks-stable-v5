include_recipe "php::install"
include_recipe "php::configure"
include_recipe "php::composer"
if ['app_master', 'app', 'solo'].include? node.dna['instance_role']
  include_recipe "php::fpm"
end