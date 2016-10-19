#
# Cookbook Name:: thinking_sphinx_3
# Recipe:: thinking_sphinx
#

# create config/thinking_sphinx.yml on all application and utility instances
if ['app_master', 'app', 'solo', 'util'].include?(node['dna']['instance_role'])

  # setup thinking sphinx on each app (see attributes)
  node['sphinx']['applications'].each do |app_name|
    # variables
    current_path = "/data/#{app_name}/current"
    shared_path = "/data/#{app_name}/shared"
    env = node['dna']['environment']['framework_env']
    
    # config yml
    template "#{shared_path}/config/thinking_sphinx.yml" do
      source "thinking_sphinx.yml.erb"
      owner node['owner_name']
      group node['owner_name']
      mode "0644"
      backup 0
      variables({
        :environment => env,
        :address => node['sphinx']['host'],
        :pid_file => "#{shared_path}/log/#{env}.sphinx.pid"
      })
    end

    #symlink config yml
    link "#{current_path}/config/thinking_sphinx.yml" do
      to "#{shared_path}/config/thinking_sphinx.yml"
      only_if { File.exist?("#{current_path}/config") }
    end

  end
end

# set up sphinx directory and run ts:config
# on sphinx instances only
if node['sphinx']['is_thinking_sphinx_instance']
  # install bundler if not present
  gem_package "bundler" do
    action :install
    not_if "gem list | grep bundler"
  end

  node['sphinx']['applications'].each do |app_name|
    # variables
    current_path = "/data/#{app_name}/current"
    shared_path = "/data/#{app_name}/shared"
    env = node['dna']['environment']['framework_env']
    
    # create sphinx directory
    directory "#{shared_path}/sphinx" do
      owner node[:owner_name]
      group node[:owner_name]
    end
    
    # remove sphinx dir
    directory "#{current_path}/db/sphinx" do
      action :delete
      recursive true
      only_if "test -d #{current_path}/db/sphinx"
    end
  
    # symlink
    link "#{current_path}/db/sphinx" do
      to "#{shared_path}/sphinx"
      only_if { File.exist?("#{current_path}/db") }
    end
  
    # ts:configure already runs on a deploy hook
    # if File.symlink?(current_path)
    #   # configure thinking sphinx
    #   execute "configure sphinx" do 
    #     command "cd #{current_path} && bundle exec rake ts:configure"
    #     user node['owner_name']
    #     environment 'RAILS_ENV' => env
    #   end
    # else
    #   Chef::Log.info "Thinking Sphinx was not configured because the application (#{app_name}) must be deployed first. Please deploy your application and then re-run the custom chef recipes."
    # end
    #
    # don't index on every chef run
    # execute "indexing" do
    #   command "cd #{current_path} && bundle exec rake ts:index"
    #   user node['owner_name']
    #   environment 'RAILS_ENV' => env
    # end
  end
end

