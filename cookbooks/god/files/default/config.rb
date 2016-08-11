# God watch files for each app are generated at /etc/god/<app_name>/node.rb
files = Dir.glob "/etc/god/**/*.rb"

files.each do |f|
  God.load f
end