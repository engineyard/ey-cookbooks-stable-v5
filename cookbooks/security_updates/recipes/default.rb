# YT-CC-924
package 'net-libs/gnutls' do
  version '3.3.28'
end

# YT-CC-1182
package 'media-libs/tiff' do
  version '4.0.8'
end

# YT-CC-1180
package 'net-misc/curl' do
  version '7.50.3'
end

# YT-GD-911
package 'dev-libs/libxml2' do
  version '2.9.4-r1'
end

# YT-CC-1212
package 'dev-libs/libgcrypt' do
  version '1.6.5-r1'
end

# YT-CC-1187
package 'app-admin/sudo' do
  version '1.8.16-r1'
end

# YT-CC-1225
package 'dev-libs/libyaml' do
  version '0.1.7'
end

# YT-GD-1021
package 'dev-libs/openssl' do
  version '1.0.2o'
end

# YT-GD-1044
package 'net-misc/openssh' do
  version '7.5_p1-r1'
end

# YT-GD-1044
# Not enabled by default since package is under testing and its impact is high
# Contact EY Support for if need to install it
#enable_package package['sys-libs/glibc'] do
#  version package['2.23-r3']
#  unmask true
#  override hardmask true
#end

#package 'sys-libs/glibc' do
#  version '2.23-r3'
#end

# YT-GD-1045
package 'media-gfx/imagemagick' do
  version '6.9.6.7'
end

# YT-GD-937
package 'media-libs/libjpeg-turbo' do
  version '1.5.3'
end

# YT-GD-1051
enable_package 'media-libs/jbig2dec' do
  version '0.14'
  unmask true
  override hardmask true
end

package 'media-libs/jbig2dec' do
  version '0.14'
end

# YT-GD-1055
enable_package 'media-libs/jasper' do
  version '2.0.14'
  unmask true
  override hardmask true
end

package 'media-libs/jasper' do
  version '2.0.14'
end

# YT-GD-1048
package 'x11-libs/gdk-pixbuf' do
  version '2.32.3-r1'
end

# YT-GD-1046
package 'dev-libs/libevent' do
  version '2.0.22-r3'
end

# YT-GD-945
package 'sys-libs/zlib' do
  version '1.2.11-r1'
end

# YT-GD-947
package 'dev-libs/icu' do
  version '57.1-r1'
end

# YT-GD-711
package 'dev-libs/libpcre' do
  version '8.42'
end

# YT-GD-1053
package 'dev-libs/nspr' do
  version '4.17'
end

# YT-GD-1047
enable_package 'dev-libs/nss' do
  version '3.29.5'
  unmask true
  override hardmask true
end

package 'dev-libs/nss' do
  version '3.29.5'
end

# YT-GD-1056
package 'media-libs/openjpeg' do
  version '2.3.0'
end

# YT-GD-922
package 'net-misc/memcached' do
  version '1.4.39'
end

# YT-GD-1058
package 'dev-db/redis' do
  version '2.8.24'
end

# YT-GD-943
package 'net-misc/ntp' do
  version '4.2.8_p11'
end

# YT-GD-1054
package 'dev-lang/perl' do
  version '5.20.2-r2'
end

# YT-GD-1054
package 'perl-core/File-Path' do
  version '2.90.0-r1'
end

# YT-GD-1054
package 'dev-perl/DBD-mysql' do
  version '4.33.0-r1'
end

# YT-GD-1062
package 'dev-lang/python' do
  version '2.7.15'
end

# YT-GD-1060
package 'net-misc/wget' do
  version '1.17.1-r2'
end

# YT-GD-1063
# Not enabled by default since package is under testing and its impact is high
# Contact EY Support for if need to install it
#enable_package 'sys-devel/binutils' do
#  version '2.29.1-r1'
#  unmask true
#  override hardmask true
#end

#package 'sys-devel/binutils' do
#  version '2.29.1-r1'
#end

# YT-GD-1064
package 'app-arch/libarchive' do
  version '3.3.2'
end

# YT-GD-1061
package 'sys-apps/busybox' do
  version '1.24.2-r1'
end

# YT-GD-821
enable_package 'net-analyzer/tcpdump' do
  version '4.9.2'
  unmask true
  override hardmask true
end

package 'net-analyzer/tcpdump' do
  version '4.9.2'
end

# YT-GD-936
package 'dev-libs/expat' do
  version '2.1.0-r6'
end

# YT-GD-1065
package 'app-editors/vim' do
  version '7.4.769-r1'
end

# YT-GD-1067
package 'dev-vcs/subversion' do
  version '1.8.19'
end

# YT-GD-1066
package 'sys-apps/shadow' do
  version '4.1.5.1-r2'
end

# YT-GD-1068
package 'net-libs/libtirpc' do
  version '0.2.5-r1'
end

# YT-GD-1068
package 'net-nds/rpcbind' do
  version '0.2.3-r2'
end

