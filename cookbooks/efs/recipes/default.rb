if node['efs']['exists'] == true
  include_recipe "efs::configure"
end

if node['efs']['exists'] == false &&
  include_recipe "efs:remove"
end
