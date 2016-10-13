if node['efs']['exists'] == true
  include_recipe "efs::configure"
end
