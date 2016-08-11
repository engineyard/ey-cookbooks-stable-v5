define :vhost do
  vhost  = params[:dna_vhost]
  book   = params[:cookbook]
  ports  = params[:upstream_ports]
  config = params[:stack_config]

  nginx_vhost vhost['domain_name'] do
    dna_vhost vhost
    cookbook  book
    upstream_ports ports
    stack_config config
  end
end
