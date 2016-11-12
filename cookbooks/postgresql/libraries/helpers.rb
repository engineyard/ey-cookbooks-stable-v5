module PostgreSQL
  module Helper
    def lock_db_version
      node.engineyard.environment.lock_db_version? ? node.engineyard.environment.components.find_all {|e| e['key'] == 'lock_db_version'}.first['value'] : false
    end

    def pg_running
      %x{psql -U postgres -t -c"select 1;" 2> /dev/null}.strip == '1'
    end
    
    def running_pg_version
      if pg_running
        %x{psql -U postgres -c'select version();' | grep -E -o 'PostgreSQL ([0-9]+\.?)+' | awk '{print $NF}'}.strip
      else
        binary_pg_version
      end
    end
    
    def binary_pg_version
      %x{psql -U postgres --version | grep PostgreSQL | awk '{print $NF}'}.strip
    end

    def add_shared_preload_library(lib)
      custom_conf = "/db/postgresql/#{node[:postgresql][:short_version]}/custom.conf"
      body = File.read(custom_conf)
      return if body[/shared_preload_libraries.*#{lib}/]
      if body[/shared_preload_libraries/]
        body.gsub!(/^(shared_preload_libraries.*'?)(.*?)('.*)$/, '\1\2,' + lib + '\3')
        File.write(custom_conf, body)
      else
        %x{echo "shared_preload_libraries = '#{lib}'" >> #{custom_conf}}
      end
    end
  end
end

Chef::Recipe.send(:include, PostgreSQL::Helper)
Chef::Resource.send(:include, PostgreSQL::Helper)
