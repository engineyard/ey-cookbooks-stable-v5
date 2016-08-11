ey_cloud_report "resque" do
  message "resque: setup"
end

include_recipe "god"

workers = begin
  total_memory_kb = nil
  File.open("/proc/meminfo", "r") do |fh|
    total_memory_line = fh.grep(/^MemTotal/).first
    total_memory_kb = total_memory_line[/(\d+)/, 1].to_i
  end

  # MB / size of one worker times 4
  total_memory_kb / 1024 / 240
end

node.engineyard.apps.each do |app|
  config = "/etc/god/resque_#{app.name}.rb"
  home   = "/home/#{node.engineyard.environment.ssh_username}"
  inline = "#{home}/.ruby_inline/#{app.name}"

  directory inline do
    action :create
    owner  node.engineyard.environment.ssh_username
    group  node.engineyard.environment.ssh_username
    recursive true
  end

  template config do
    owner "root"
    group "root"
    mode 0644
    source "resque.rb.erb"
    variables(
      :home     => home,
      :inline   => inline,
      :app_root => "/data/#{app.name}/current",
      :owner    => node.engineyard.environment.ssh_username,
      :watch    => "resque-#{app.name}",
      :env      => node.dna['environment']['framework_env'],
      :instance => node.instance.id,
      :workers  => workers
    )
  end

  execute_after_deploy "god load #{config}" do
    command "god load #{config}"
  end
end
