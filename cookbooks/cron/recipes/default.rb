#
# Cookbook Name:: cron
# Recipe:: default
#

# Find all cron jobs specified in attributes/cron.rb where current node name matches instance_name
named_crons = node[:custom_crons].find_all {|c| c[:instance_name] == node.dna[:name] }

# Find all cron jobs for utility instances
util_crons = node[:custom_crons].find_all {|c| c[:instance_name] == 'util' }

# Find all cron jobs for application instances
app_crons = node[:custom_crons].find_all {|c| c[:instance_name] == 'app' }

# Find all cron jobs for ALL instances
all_crons = node[:custom_crons].find_all {|c| c[:instance_name] == 'all' }

# Find all cron jobs for Database instances
db_crons = node[:custom_crons].find_all {|c| c[:instance_name] == 'db' }

# Find all cron jobs for App_Master
appmaster_crons = node[:custom_crons].find_all {|c| c[:instance_name] == 'app_master' }

crons = all_crons + named_crons


if node['dna']['instance_role'] == 'util'
    crons = crons + util_crons
end

if node['dna']['instance_role'] == 'app' || node['dna']['instance_role'] == 'app_master'
    crons = crons + app_crons
end

if node['dna']['instance_role'] == 'db_master' || node['dna']['instance_role'] == 'db_slave'
    crons = crons + db_crons
end

if node['dna']['instance_role'] == 'app_master'
    crons = crons + appmaster_crons
end

crons.each do |cron|
  cron cron[:name] do
    user     node['owner_name']
    action   :create
    minute   cron[:time].split[0]
    hour     cron[:time].split[1]
    day      cron[:time].split[2]
    month    cron[:time].split[3]
    weekday  cron[:time].split[4]
    command  cron[:command]
  end
end


