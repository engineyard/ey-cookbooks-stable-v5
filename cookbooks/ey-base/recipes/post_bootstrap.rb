include_recipe "monit"
include_recipe "collectd"
include_recipe "newrelic"
include_recipe "node::common"
include_recipe "reboot"

file "/etc/engineyard/recipe-revision.txt" do
  action :touch
  mode 0644
end

bash "add-chef-dracul-revision-sha" do
  code "sha1sum /etc/engineyard/dracul.yml | cut -c 1-40 > /etc/engineyard/recipe-revision.txt"
end
