include_recipe "ruby::common"

component = node.engineyard.environment.ruby

template "/home/#{node.engineyard.environment.ssh_username}/.jrubyrc" do
  source 'jrubyrc.erb'
  owner node.engineyard.environment.ssh_username
  group node.engineyard.environment.ssh_username
  mode 0755
  backup 0
#  cookbook 'trinidad'

  variables(:compat_version => component[:mode])
end

template "/root/.jrubyrc" do
  source 'jrubyrc.erb'
  owner 'root'
  group 'root'
  mode 0755
  backup 0

  variables(:compat_version => component[:mode])
end

%w(ruby irb gem).each do |executible|
  link "/usr/bin/#{executible}" do
    to "/usr/bin/j#{executible}"
  end
end
