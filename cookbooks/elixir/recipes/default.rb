if ['app_master', 'app', 'solo'].include? node['dna']['instance_role']
  include_recipe "elixir::nginx"
end
include_recipe "elixir::install"
include_recipe "elixir::configure"
