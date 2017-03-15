#
# Drop an /etc/motd file on the VM to educate a user
# about where relevant files/folders are located
# and how to do useful activities (tail logs)
#

# Application data is in two places in +node+:
# * node.dna['applications']
# * node.dna['engineyard'][:environment][:apps]
#
# It is passed into the templates looking like:
# {
#   "app_name": {
#     "database_name": "app_name",
#     "recipes": [
#       "monit",
#       "nginx",
#       "passenger3"
#     ]
#   },
#   "app_name2": {...}
# }

applications = node.dna['applications']
environment_apps = node.engineyard.environment.apps
# node.dna['engineyard'][:environment][:apps] looks like:
# [
#   {
#     "name": "jerryseinfeld",
#     "database_name": "jerryseinfeld",
#   ...

apps_and_recipes = applications.inject({}) do |apps, app_data|
  app_name, data = app_data
  environment_app = environment_apps.find {|app| app[:name] == app_name}
  apps[app_name] = {
    :recipes => data[:recipes],
    :database_name => environment_app[:database_name]
  }
  apps
end

prechef_command_account = metadata_account_get("prechef_command")
prechef_command_env = metadata_env_get("prechef_command")
prechef_command_app = metadata_any_app_get("prechef_command")

logs = db_log_paths

if ['solo'].include?(node.dna.instance_role)
  template "/etc/motd" do
    source "motd-solo.erb"
    owner "root"
    group "root"
    mode 0655
    variables({
      :apps_and_recipes => apps_and_recipes, # see above
      :framework_env => node.engineyard.environment['framework_env'], # 'production'
      :db_type => node.engineyard.environment['db_stack_name'], # 'postgresql'
      :db_logs => logs,
      :prechef_cmd_account => prechef_command_account,
      :prechef_cmd_env => prechef_command_env,
      :prechef_cmd_app => prechef_command_app
    })
  end

elsif ['app_master', 'app', 'util'].include?(node.dna.instance_role)
  template "/etc/motd" do
    source "motd-app-util.erb"
    owner "root"
    group "root"
    mode 0655
    variables({
      :apps_and_recipes => apps_and_recipes, # see above
      :framework_env => node.engineyard.environment['framework_env'], # 'production'
      :prechef_cmd_account => prechef_command_account,
      :prechef_cmd_env => prechef_command_env,
      :prechef_cmd_app => prechef_command_app
    })
  end

elsif ['db_master', 'db_slave'].include?(node.dna.instance_role)
  template "/etc/motd" do
    source "motd-db.erb"
    owner "root"
    group "root"
    mode 0655
    variables({
      :apps_and_recipes => apps_and_recipes, # see above
      :db_type => node.engineyard.environment['db_stack_name'],
      :db_logs => logs,
      :prechef_cmd_account => prechef_command_account,
      :prechef_cmd_env => prechef_command_env,
      :prechef_cmd_app => prechef_command_app
    })
  end

end
