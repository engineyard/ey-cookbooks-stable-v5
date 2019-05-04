node['dna']['engineyard']['environment']['apps'].each do |app_data|
  if ['app_master', 'app', 'solo'].include?(node.dna['instance_role'])
    app_env_vars = fetch_environment_variables(app_data)
    app_env_vars.each do |aev|
      if aev[:name].include? "HAPROXY_CERT"
        custom_cert_name = aev[:name]
        custom_cert_contents = fetch_custom_ssl_pem(app_data, aev)
        file "/data/nginx/ssl/#{custom_cert_name}.pem" do
          mode 0644
          owner node["owner_name"]
          group node["owner_name"]
          action :create
          content custom_cert_contents
        end
      end
    end
  end
end
