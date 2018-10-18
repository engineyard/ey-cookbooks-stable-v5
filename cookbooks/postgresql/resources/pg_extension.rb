resource_name :pg_extension

property :ext_name, [String, Array], required: true
property :db_name, [String, Array], required: true
property :schema_name, String
property :version, String
property :old_version, String
property :use_load, [TrueClass, FalseClass], default: false # use LOAD instead of CREATE EXTENSION

action :install do
  ext_names = ext_name.kind_of?(String) ? [ext_name] : ext_name
  db_names = db_name.kind_of?(String) ? [db_name] : db_name
  postgres_version = node[:postgresql][:short_version]

  if node[:dna][:instance_role][/^(db|solo)/]
    ext_names.each do |ext_name|
      ext_details = node[:pg_ext_details][ext_name] || {}

      # Postgis needs some package work
      include_recipe 'postgresql::postgis_build' if ext_name[/^postgis/]

      db_names.each do |db_name|
        # bail with a log message if the extension isn't supported for the active Postgres major version
        if (!ext_details[:min_pg_version].nil? and postgres_version_lt?(ext_details[:min_pg_version])) || (!ext_details[:max_pg_version].nil? and postgres_version_gt?(ext_details[:max_pg_version]))
          Chef::Log.info "PostgreSQL extension #{ext_name} is only supported on versions #{ext_details[:min_pg_version]} #{!ext_details[:max_pg_version].nil? ? "to " + ext_details[:max_pg_version].to_s : "and higher"}. Currently installed version: #{postgres_version}."
          break
        end

        # the main extension/library install bit
        if node[:dna][:instance_role][/db_master|solo/]
          Chef::Log.info "Installing PostgreSQL extension #{ext_name} to database #{db_name}."
          do_load = ext_details[:use_load].nil? ? (use_load || false) : (ext_details[:use_load] || use_load)
          if do_load
            cmd = 'LOAD'
            quoted_ext_name = "'#{ext_name}'"
          else
            cmd = 'CREATE EXTENSION IF NOT EXISTS'
            quoted_ext_name = %Q(\\"#{ext_name}\\")
          end
          execute "Postgresql loading #{do_load ? 'library': 'extension'} #{ext_name}" do
            command %Q(psql -U postgres -d #{db_name} -c "#{cmd} #{quoted_ext_name} #{"SCHEMA #{schema_name}" if !schema_name.nil? } #{"VERSION #{version}" if !version.nil?} #{"FROM #{old_version}" if !old_version.nil?};")
          end

          # and a couple follow up commands for Postgis
          if ext_name[/postgis/]
            execute "Updating to correct postgis minor version" do
              # this is essentially a no-op if already on this version.
              command %Q(psql -U postgres -d #{db_name} -c 'ALTER EXTENSION postgis UPDATE TO "#{node[:postgis_version]}";')
            end

            execute "Grant permissions to the #{node.engineyard.environment.ssh_username} user on the geometry_columns schema" do
              command %Q(psql -U postgres -d #{db_name} -c "GRANT all on geometry_columns to #{node.engineyard.environment.ssh_username}")
            end

            execute "Grant permissions to the #{node.engineyard.environment.ssh_username} user on the spatial_ref_sys schema" do
              command %Q(psql -U postgres -d #{db_name} -c "GRANT all on spatial_ref_sys to #{node.engineyard.environment.ssh_username}")
            end
          end
        end

        # these needs some configuration
        include_recipe 'postgresql::auto_explain' if ext_name == 'auto_explain'
        include_recipe 'postgresql::pg_stat_statements' if ext_name == 'pg_stat_statements'
      end
    end
  end
end
