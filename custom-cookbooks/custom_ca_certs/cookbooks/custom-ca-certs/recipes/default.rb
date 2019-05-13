node['dna']['engineyard']['environment']['apps'].each do |app_data|
  app_env_vars = fetch_environment_variables(app_data)
  app_env_vars.each do |aev|
    if aev[:name].include? "CA_CERT"
      custom_ca_cert_name = aev[:name]
      custom_ca_cert_contents = fetch_custom_ca_pem(app_data, aev)
      file "/usr/share/ca-certificates/mozilla/#{custom_ca_cert_name}.cert" do
        mode 0644
        action :create
        content custom_ca_cert_contents
      end
      link "/etc/ssl/certs/#{custom_ca_cert_name}.pem" do
        to "/usr/share/ca-certificates/mozilla/#{custom_ca_cert_name}.cert"
      end
      execute "Update CA Certificates" do
        command 'update-ca-certificates'
      end
    end
  end
end
