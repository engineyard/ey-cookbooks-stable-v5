# YT-CC-924
# FB-549
package 'net-libs/gnutls' do
  version '3.3.30'
end

# YT-CC-1182
# YT-CC-1351
# YT-CC-1338
package 'media-libs/tiff' do
  version '4.0.8-r1'
end

# YT-CC-1254
# YT-CC-1351
# YT-CC-1285
# FB-549
package 'net-misc/curl' do
  version '7.50.3-r4'
end

# YT-CC-1254
package 'dev-libs/libxml2' do
  version '2.9.4-r1'
end

# YT-CC-1212
package 'dev-libs/libgcrypt' do
  version '1.6.5-r1'
end

# CC-1187
package 'app-admin/sudo' do
  version '1.8.16-r1'
end

# YT-CC-1225
package 'dev-libs/libyaml' do
  version '0.1.7'
end

# YT-CC-1320
# FB-657
package 'www-servers/nginx' do 
  action :nothing
  version '1.12.2'
  notifies :restart, 'service[nginx]'
end