god_version = '0.13.7'

ey_cloud_report "god" do
  message "processing god"
end

#gem_package "god" do
#  action :install
#  version "0.11.0"
#end

execute "install god" do
  command "gem install god -v #{god_version}; ln -s /usr/local/bin/god /usr/bin/god"
  not_if { FileTest.exists?("/usr/local/bin/god") }
end

directory "/etc/god" do
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/etc/god/config" do
  owner "root"
  group "root"
  mode 0700
  source "config.rb"
end

inittab "god" do
  command "/usr/local/bin/god -c /etc/god/config -l /var/log/god.log --log-level info -D"
  action :respawn
end

inittab "god0" do
  command "/usr/local/bin/god quit"
  action :wait
  runlevel 0, 6
end
