default['nodejs']['version'] = node.engineyard.environment.metadata('nodejs_version','4.4.5')
default['nodejs']['available_versions'] = [
  '0.12.6',  # net-libs/nodejs-0.12.6
  '0.12.7',  # net-libs/nodejs-0.12.7
  '0.12.10',  # net-libs/nodejs-0.12.10
  '4.4.0', # net-libs/nodejs-4.4.0
  '4.4.1', # net-libs/nodejs-4.4.1
  '4.4.5', # net-libs/nodejs-4.4.5
  '5.9.1', # net-libs/nodejs-5.9.1
  '5.10.1', # net-libs/nodejs-5.10.1
  '5.11.0', # net-libs/nodejs-5.11.0
  '6.4.0' # net-libs/nodejs-6.4.0
]

if (node.engineyard.metadata('openssl_ebuild_version','1.0.1') =~ /1\.0\.1/)
  default['nodejs']['available_versions'].concat ([
    '0.12.6',  # net-libs/nodejs-0.12.6
    '0.12.7',  # net-libs/nodejs-0.12.7
    '0.12.10',  # net-libs/nodejs-0.12.10
    '4.4.0', # net-libs/nodejs-4.4.0
    '4.4.1', # net-libs/nodejs-4.4.1
    '4.4.5', # net-libs/nodejs-4.4.5
    '5.9.1', # net-libs/nodejs-5.9.1
    '5.10.1', # net-libs/nodejs-5.10.1
    '5.11.0', # net-libs/nodejs-5.11.0
    '6.4.0' # net-libs/nodejs-6.4.0

  ])
end

# Note: see cookbooks/node/recipes/common.rb to set the package for any new versions

default['coffeescript']['version'] = node.engineyard.metadata('coffeescript_version','1.9.3')
