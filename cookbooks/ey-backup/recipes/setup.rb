ey_cloud_report "backups" do
  message 'processing backups'
end

directory "/mnt/backups" do
  owner node["owner_name"]
  group node["owner_name"]
  mode 0755
end

