component = node.engineyard.environment.ruby

ruby_mask = nil
ruby_dependencies = {}

if component[:version] =~ /^2\.0[\d\.]*\b/
  ruby_mask = '-ruby_targets_ruby20'
  ruby_dependencies = {
    'dev-ruby/rubygems' => '1.8.24-r1'
  }
end

if component[:version] =~ /^2\.1[\d\.]*\b/
  ruby_mask = '-ruby_targets_ruby21'
  ruby_dependencies = {
    "dev-ruby/json"     => "1.8.1",
    "dev-ruby/racc"     => "1.4.11",
    "dev-ruby/rake"     => "0.9.6-r1",
    "dev-ruby/rdoc"     => "4.0.1-r2",
    "dev-ruby/rubygems" => "2.0.14",
  }
end

if component[:version] =~ /^2\.2[\d\.]*\b/
  ruby_mask = '-ruby_targets_ruby22'
  ruby_dependencies = {
    "dev-ruby/json"     => "1.8.2",
    "dev-ruby/racc"     => "1.4.11-r1",
    "dev-ruby/rake"     => "0.9.6-r2",
    "dev-ruby/rdoc"     => "4.0.1-r3",
    "dev-ruby/rubygems" => "2.0.14-r1",
  }
end

if component[:version] =~ /^2\.3[\d\.]*\b/
  ruby_mask = '-ruby_targets_ruby23'
  ruby_dependencies = {
    "dev-ruby/json"     => "1.8.2-r1",
    "dev-ruby/racc"     => "1.4.11-r2",
    "dev-ruby/rake"     => "0.9.6-r3",
    "dev-ruby/rdoc"     => "4.0.1-r4",
    "dev-ruby/rubygems" => "2.0.14-r2",
  }
end

unmask_package component[:package] do
  version component[:version]
  unmaskfile "ruby"
end


use_mask ruby_mask do
  mask_file "ruby"
  only_if "ruby_mask"
end


ruby_dependencies.each do |dep, dep_version|
  enable_package dep do
    version dep_version
  end
end

include_recipe 'ruby::common'

execute "install-modern-rack" do
  command "gem install rack -v 1.0.1"
  only_if { component[:full_version] =~ /^ruby-1\.8\.6/ }
end
