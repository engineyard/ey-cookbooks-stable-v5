include_recipe "node::common"

bash 'install CoffeeScript' do
  code "/usr/bin/npm install -g coffee-script@#{node.dna['coffeescript']['version']}"
end
