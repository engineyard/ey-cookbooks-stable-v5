if attribute['efs']['exists'] == true do
  include_recipe "efs::configure"
end
