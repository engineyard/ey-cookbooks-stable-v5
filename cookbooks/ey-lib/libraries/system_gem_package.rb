module SystemRubyGemPackage
  def gem_package(*args, &blk)
    resource = super(*args, &blk)
    resource.gem_binary("/usr/bin/gem") if resource.respond_to? :gem_binary
    resource
  end
end

class Chef::Recipe
  include SystemRubyGemPackage
end

