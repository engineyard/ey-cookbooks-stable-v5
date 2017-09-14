# Elasticsearch 5.x requires higher limits for max files descriptors and vm.max_map_count

# Override /etc/security/limits.conf
# NOTE: If you have recipes that also override /etc/security/limits.conf then
# you have to integrate your customizations here

cookbook_file "/etc/security/limits.conf" do
  source "etc-security-limits.conf"
  owner "root"
  group "root"
  mode 600
end

# Override the monit wrapper
cookbook_file "/usr/local/bin/monit" do
  source "usr-local-bin-monit"
  owner "root"
  group "root"
  mode 600
end
