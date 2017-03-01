include_recipe 'mysql::client'

mysql_slave node.dna['db_host'] do
  password node['owner_pass']
end

def self.mysql_slave_is_slavey?
  begin
    foo = `mysql -e "show slave status"`
    !foo.empty?
  rescue
    false
  end
end

# Only run the mysql_slave recipes if it isn't already a slave
updating = false

resources_collection = Chef::VERSION == '0.6.0.2' ? collection : run_context.resource_collection

resources_collection.each do |r|
  updating = true if r.to_s == "execute[start-of-mysql-slave]"
  updating = false if r.to_s == "execute[stop-of-mysql-slave]"

  if updating && (!r.not_if or r.not_if.empty?)
    # Chef::Log.info("-----Dynamically adding not_if to resource #{r.to_s})
    r.not_if do # sets a not_if on the individual resource
      mysql_slave_is_slavey?
    end
  end
end

handle_mysql_d
