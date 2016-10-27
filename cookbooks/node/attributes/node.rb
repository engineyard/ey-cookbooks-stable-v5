env_components = attribute['dna']['engineyard']['environment']['components']

hard_version = begin
                 env_components.find {|node| node['key'] == 'nodejs'}['value']
               rescue NoMethodError
                 nil
               end


fuzzy_version = begin
                  env_components.map(&:values).flatten.find {|value| value =~ /^nodejs_/}
                rescue NoMethodError
                  nil
                end

fallback_nodejs_version = case (fuzzy_version || hard_version)
                           when 'nodejs_6'
                             '6.4.0'
                           when 'nodejs_5'
                             '5.11.0'
                           else
                             '4.4.5'
                           end

default['nodejs']['version'] = node.engineyard.environment.metadata('nodejs_version', fallback_nodejs_version)

default['nodejs']['available_versions'] = [
  '4.4.5', # net-libs/nodejs-4.4.5
  '4.6.0', # net-libs/nodejs-4.6.0
  '5.11.0', # net-libs/nodejs-5.11.0
  '6.4.0', # net-libs/nodejs-6.4.0
  '6.7.0' # net-libs/nodejs-6.7.0
]

if (node.engineyard.metadata('openssl_ebuild_version','1.0.1') =~ /1\.0\.1/)
  default['nodejs']['available_versions'].concat ([
    '4.4.5', # net-libs/nodejs-4.4.5
    '4.6.0', # net-libs/nodejs-4.6.0
    '5.11.0', # net-libs/nodejs-5.11.0
    '6.4.0', # net-libs/nodejs-6.4.0
    '6.7.0' # net-libs/nodejs-6.7.0

  ])
end

#Note Libuv is required for newer nodejs versions
default['nodejs']['libuv']['version'] = '1.9.1'

# Note: see cookbooks/node/recipes/common.rb to set the package for any new versions

default['coffeescript']['version'] = node.engineyard.metadata('coffeescript_version','1.9.3')
