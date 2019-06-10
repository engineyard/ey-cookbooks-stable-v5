module RubyHelpers
  def ruby2x?(x, version_string)
    version_string =~ /^2\.#{x}\.[\d\.]*\b/
  end

  def ruby_minor_version(version_string)
    version_string.split('.')[1]
  end

  def ruby2x_mask(version_string)
    "-ruby_targets_ruby2#{ruby_minor_version(version_string)}"
  end
end

class Chef::Recipe
  include RubyHelpers
end

class Chef::Node
  include RubyHelpers
end
