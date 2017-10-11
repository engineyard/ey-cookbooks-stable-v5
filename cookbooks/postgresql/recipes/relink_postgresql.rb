link_file = "/etc/engineyard/.postgresql-#{node['postgresql']['short_version']}.ey-resin-pg-re-linked"

file link_file do
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end

execute "re-link-postgresql" do
  command "/usr/local/ey_resin/ruby/bin/gem install pg -v 0.9 --no-ri --no-rdoc"
  notifies :touch, "file[#{link_file}]", :immediate
  not_if { File.exists?(link_file) }
end
