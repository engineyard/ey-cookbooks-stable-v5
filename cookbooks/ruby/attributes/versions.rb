component = node.engineyard.environment.ruby
ruby_version = component[:version]

default[:ruby_dependencies] = {}
default[:do_upgrade_eselect_ruby] = false

if ruby2x?(0, ruby_version)
  default[:ruby_dependencies] = {
    'dev-ruby/rubygems' => '1.8.24-r1'
  }
elsif ruby2x?(1, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.1",
    "dev-ruby/racc"     => "1.4.11",
    "dev-ruby/rake"     => "0.9.6-r1",
    "dev-ruby/rdoc"     => "4.0.1-r2",
    "dev-ruby/rubygems" => "2.0.14",
  }
elsif ruby2x?(2, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.2",
    "dev-ruby/racc"     => "1.4.11-r1",
    "dev-ruby/rake"     => "0.9.6-r2",
    "dev-ruby/rdoc"     => "4.0.1-r3",
    "dev-ruby/rubygems" => "2.0.14-r1",
  }
elsif ruby2x?(3, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.2-r1",
    "dev-ruby/racc"     => "1.4.11-r2",
    "dev-ruby/rake"     => "0.9.6-r3",
    "dev-ruby/rdoc"     => "4.0.1-r4",
    "dev-ruby/rubygems" => "2.0.14-r2",
  }
elsif ruby2x?(4, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"         => "2.0.3",
    "dev-ruby/racc"         => "1.4.14-r1",
    "dev-ruby/rake"         => "12.0.0",
    "dev-ruby/rdoc"         => "5.1.0",
    "dev-ruby/rubygems"     => "2.6.14",
    "dev-ruby/did_you_mean" => "1.1.0",
    "dev-ruby/kpeg"         => "1.1.0",
    "dev-ruby/minitest"     => "5.10.1",
    "dev-ruby/net-telnet"   => "0.1.1-r2",
    "dev-ruby/power_assert" => "0.4.1",
    "dev-ruby/test-unit"    => "3.2.3",
    "dev-ruby/xmlrpc"       => "0.2.1",
    "virtual/rubygems"      => "12",
  }
elsif ruby2x?(5, ruby_version)
  default[:do_upgrade_eselect_ruby] = true
  default[:ruby_dependencies] = {
    "dev-ruby/json"         => "2.0.3-r1",
    "dev-ruby/racc"         => "1.4.14-r2",
    "dev-ruby/rake"         => "12.3.0",
    "dev-ruby/rdoc"         => "6.0.3",
    "dev-ruby/rubygems"     => "2.7.6",
    "dev-ruby/did_you_mean" => "1.2.0",
    "dev-ruby/kpeg"         => "1.1.0-r1",
    "dev-ruby/minitest"     => "5.10.3",
    "dev-ruby/net-telnet"   => "0.1.1-r3",
    "dev-ruby/power_assert" => "1.1.1",
    "dev-ruby/test-unit"    => "3.2.7",
    "dev-ruby/xmlrpc"       => "0.3.0",
    "virtual/rubygems"      => "13",
  }
end
