if attribute['efs']['exists'] == true
  include_recipe "efs::configure"
end
