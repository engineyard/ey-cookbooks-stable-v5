link_path = "/etc/engineyard/.mysql-#{node['mysql']['short_version']}"

file "#{link_path}.system.dbd-re-linked" do
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end

file "#{link_path}.system.sphinx.re-linked" do
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end

# always install latest available DBD-mysql when this runs
dbd_opts = "dev-perl/DBD-mysql"

execute "re-link-dbd" do
  command "emerge --ignore-default-opts #{dbd_opts}"
  notifies :touch, "file[#{link_path}.system.dbd-re-linked]", :immediate
  not_if { File.exists?("#{link_path}.system.dbd-re-linked") }
end

# only install the current sphinx version during re-link, we don't want to inadvertently upgrade this
sphinx_opts = "=" + %x{cd /var/db/pkg && ls -d app-misc/sphinx-*}.chomp
sphinx_opts = "app-misc/sphinx" if sphinx_opts == "="

execute "re-link-sphinx" do
  command "emerge --ignore-default-opts #{sphinx_opts}"
  notifies :touch, "file[#{link_path}.system.sphinx.re-linked]", :immediate
  not_if { File.exists?("/data/please_allow_me_to_customize_sphinx") || File.exists?("#{link_path}.system.sphinx.re-linked") }
end
