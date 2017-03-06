# Installs latest Yarn and sets up links properly
# TODO:  Execute the recipe only if a newer version of yarn is available
# (check by hitting https://github.com/yarnpkg/yarn/releases/latest and grabbing the redirection)

yarn_download_url = "https://yarnpkg.com/latest.tar.gz"

directory "/tmp/yarn" do
  recursive true
  action :delete
end

directory "/tmp/yarn" do
  mode 0755
  action :create
end

remote_file "/tmp/yarn/yarn-latest.tar.gz" do
  source "#{yarn_download_url}"
  mode 0644
  backup 0
end

execute "unarchive Yarn" do
  cwd "/tmp/yarn"
  command "tar zxf yarn-latest.tar.gz"
end

yarn_version = `grep version /tmp/yarn/dist/package.json | awk -F: {'print $2'} | sed -e 's/ //' -e 's/\"//g' -e 's/,//'`.chomp

#create yarn installation folder
directory "/opt/yarn-#{yarn_version}" do
  mode 0755
  action :create
end

execute "move Yarn to its folder under /opt" do
  cwd "/tmp/yarn/dist"
  command "mv * /opt/yarn-#{yarn_version}"
end

link "/usr/bin/yarn" do
  to "/opt/yarn-#{yarn_version}/bin/yarn"
end

link "/usr/bin/yarnpkg" do
  to "/opt/yarn-#{yarn_version}/bin/yarnpkg"
end



