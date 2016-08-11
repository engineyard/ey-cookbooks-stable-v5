#action :list

attribute :name, :kind_of => String, :required => true
attribute :newrelic, :default => false
attribute :auth, :default => false
attribute :type, :kind_of => String, :required => true, :default => "rack"
attribute :repository_uri, :kind_of => String, :required => true
attribute :repository_branch, :king_of => String, :required => true, :default => "master"
attribute :http_ports, :kind_of => Array, :required => true, :default => ["80", "443"]
attribute :repository_revision, :kind_of => String, :required => false
attribute :run_deploy, :default => false, :required => true
attribute :deploy_key, :kind_of => String, :required => true
attribute :deploy_action, :kind_of => String, :required => true, :default => "deploy"
attribute :run_migrations, :default => false, :required => true
