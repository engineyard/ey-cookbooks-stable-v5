define :es_plugin, :name => nil do
  name = params['name']

  case params['action'].to_sym
  when :install
    Chef::Log.info "attempting to install ElasticSearch plugin #{name}"

    execute "plugin install #{name}" do
      cwd "/opt/elasticsearch"
      command "/opt/elasticsearch/bin/plugin -install #{name}"
      not_if { File.directory?("/opt/elasticsearch/plugins/#{name}") }
    end

  when :remove
    Chef::Log.info "attempting to remove ElasticSearch plugin #{name}"

    execute "plugin remove #{name}" do
      cwd "/opt/elasticsearch"
      command "/opt/elasticsearch/bin/plugin -remove #{name}"
      not_if { File.directory?("/opt/elasticsearch/plugins/#{name}") }
    end
  end
end
