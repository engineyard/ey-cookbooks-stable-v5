managed_template "/etc/local.d/9999_reboot.start" do
  source "9999_reboot.start.erb"
  owner "root"
  group "root"
  mode "0755"
end
