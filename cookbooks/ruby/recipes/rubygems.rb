if node.engineyard.environment.ruby?  
  ensure_rubygems_version

  # removing packaged bundler prevents the error "You must use Bundler 2 or greater with this lockfile"
  # engineyard-serverside installs bundler during deploys
  execute "remove bundler installed by rubygems" do
    command "rm -rf /usr/lib64/ruby/site_ruby/*/bundler{,.rb} && rm -f /usr/local/lib64/ruby/gems/*/specifications/default/bundler*gemspec"
  end
end
