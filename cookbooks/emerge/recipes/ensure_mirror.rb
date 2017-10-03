cookbook_file "/etc/portage/mirrors" do
  owner "root"
  group "root"
  mode 0700
  source "portage-mirror"
end
