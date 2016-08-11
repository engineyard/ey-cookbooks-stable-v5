#TODO: uber hacks are uber
(node.dna[:removed_applications]||[]).each do |app|
  directory "/data/nginx/servers/#{app}" do
    action :delete
    recursive true
    notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
  end

  file "/data/nginx/servers/#{app}.conf" do
    action :delete
    notifies node['nginx'][:action], resources(:service => "nginx"), :delayed
  end
end
