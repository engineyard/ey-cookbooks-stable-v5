if node.engineyard.environment.ruby?
  ruby_version = node.engineyard.environment.ruby[:version]
else
  ruby_version = '' 
end

default[:ruby_dependencies] = {}
default[:do_upgrade_eselect_ruby] = false
default[:ruby_jemalloc_available] = false

if ruby2x?(0, ruby_version)
  default[:ruby_dependencies] = {
    'dev-ruby/rubygems' => '2.6.4'
  }
elsif ruby2x?(1, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.3",
    "dev-ruby/racc"     => "1.4.14",
    "dev-ruby/rake"     => "11.1.2",
    "dev-ruby/rdoc"     => "4.2.2",
    "dev-ruby/rubygems" => "2.6.4",
  }
elsif ruby2x?(2, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.3",
    "dev-ruby/racc"     => "1.4.14",
    "dev-ruby/rake"     => "11.1.2",
    "dev-ruby/rdoc"     => "4.2.2",
    "dev-ruby/rubygems" => "2.6.4",
  }
elsif ruby2x?(3, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"     => "1.8.3",
    "dev-ruby/racc"     => "1.4.14",
    "dev-ruby/rake"     => "11.1.2",
    "dev-ruby/rdoc"     => "4.2.2",
    "dev-ruby/rubygems" => "2.6.14-r1",
  }
elsif ruby2x?(4, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/json"         => "2.0.3",
    "dev-ruby/racc"         => "1.4.14-r1",
    "dev-ruby/rake"         => "12.0.0",
    "dev-ruby/rdoc"         => "5.1.0",
    "dev-ruby/rubygems"     => "2.6.14-r1",
    "dev-ruby/did_you_mean" => "1.1.0",
    "dev-ruby/kpeg"         => "1.1.0",
    "dev-ruby/minitest"     => "5.10.1",
    "dev-ruby/net-telnet"   => "0.1.1-r2",
    "dev-ruby/power_assert" => "0.4.1",
    "dev-ruby/test-unit"    => "3.2.3",
    "dev-ruby/xmlrpc"       => "0.2.1",
    "virtual/rubygems"      => "12",
  }
  default[:ruby_jemalloc_available] = true
elsif ruby2x?(5, ruby_version)
  default[:do_upgrade_eselect_ruby] = true
  default[:ruby_dependencies] = {
    "dev-ruby/json"         => "2.0.3-r1",
    "dev-ruby/racc"         => "1.4.14-r2",
    "dev-ruby/rake"         => "12.3.0",
    "dev-ruby/rdoc"         => "6.0.3",
    "dev-ruby/rubygems"     => "2.7.9",
    "dev-ruby/did_you_mean" => "1.2.0",
    "dev-ruby/kpeg"         => "1.1.0-r1",
    "dev-ruby/minitest"     => "5.10.3",
    "dev-ruby/net-telnet"   => "0.1.1-r3",
    "dev-ruby/power_assert" => "1.1.1",
    "dev-ruby/test-unit"    => "3.2.7",
    "dev-ruby/xmlrpc"       => "0.3.0",
    "virtual/rubygems"      => "13",
  }
  default[:ruby_jemalloc_available] = true
elsif ruby2x?(6, ruby_version)
  default[:ruby_dependencies] = {
    "dev-ruby/bundler"      => "1.17.3",
    "dev-ruby/json"         => "2.0.3-r2",
    "dev-ruby/racc"         => "1.4.14-r3",
    "dev-ruby/rake"         => "12.3.2",
    "dev-ruby/rdoc"         => "6.0.3-r1",
    "dev-ruby/rubygems"     => "3.0.3",
    "dev-ruby/did_you_mean" => "1.3.0",
    "dev-ruby/minitest"     => "5.11.3",
    "dev-ruby/net-telnet"   => "0.2.0",
    "dev-ruby/power_assert" => "1.1.4",
    "dev-ruby/test-unit"    => "3.2.9",
    "dev-ruby/xmlrpc"       => "0.3.0-r1",
    "dev-ruby/kpeg"         => "1.1.0-r2",
    "virtual/rubygems"      => "14",
  }
  default[:ruby_jemalloc_available] = true
end
