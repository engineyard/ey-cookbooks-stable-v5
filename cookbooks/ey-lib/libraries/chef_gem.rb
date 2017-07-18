class Chef
  class Resource
    class ChefGem < Chef::Resource::Package::GemPackage
      resource_name :chef_gem
      property :gem_binary, default: "/home/ey/bin/gem"
    end
  end
end
