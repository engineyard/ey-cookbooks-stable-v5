cookbook_file "/etc/portage/mirrors" do
  owner "root"
  group "root"
  mode 0444
  source "portage-mirror"
end
