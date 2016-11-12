custom_conf = "/db/postgresql/#{node[:postgresql][:short_version]}/custom.conf"

body = ''
ruby_block 'add auto_explain to custom.conf' do
  block do
    body = ::File.read(custom_conf)
    body += <<-EOF

auto_explain.log_min_duration = '3s'
auto_explain.log_analyze = 'false'
auto_explain.log_verbose = 'false'
auto_explain.log_buffers = 'false'
auto_explain.log_format = 'text'
auto_explain.log_nested_statements = 'false'
EOF
    File.write(custom_conf, body)
    add_shared_preload_library('auto_explain')
  end
  not_if "[ -e #{custom_conf} ] && grep auto_explain #{custom_conf}"
end

# file "configure auto_explain" do
#   action :create
#   path custom_conf
#   content lazy { body }
#   not_if "[ -e #{custom_conf} ] && grep auto_explain #{custom_conf}"
# end

execute "reload postgres service" do
  command "/etc/init.d/postgresql-#{node[:postgresql][:short_version]} reload"
end
