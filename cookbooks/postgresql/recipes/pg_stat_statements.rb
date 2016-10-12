custom_conf = "/db/postgresql/#{node[:postgresql][:short_version]}/custom.conf"

body = ''
ruby_block 'add pg_stat_statements to custom.conf' do
  block do
    body = File.read(custom_conf)
    body += <<-EOF

pg_stat_statements.max = 10000
pg_stat_statements.track = all
EOF
    File.write(custom_conf, body)
    add_shared_preload_library('pg_stat_statements')
  end
  not_if "[ -e #{custom_conf} ] && grep pg_stat_statements #{custom_conf}"
end

Chef::Log.info("The pg_stat_statements extension has been created but a server restart is needed to load the module for it to work.")
