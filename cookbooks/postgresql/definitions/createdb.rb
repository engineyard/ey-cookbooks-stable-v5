define :createdb, :user => 'postgres' do
  db_name = params[:name].downcase
  owner = params[:owner]

if ['solo', 'db_master'].include?(node['dna']['instance_role'])
    execute "create database for #{db_name}" do
      command %{psql -U postgres postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
      not_if %{psql -U postgres -t -c "select datname from pg_database where datname = '#{db_name}';" | grep #{db_name}}
    end
  end
end
