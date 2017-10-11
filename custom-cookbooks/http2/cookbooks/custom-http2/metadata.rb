name 'custom-http2'
description 'Configure haproxy/nginx to use http2 on Engine Yard'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
maintainer 'Engine Yard'
maintainer_email 'support@engineyard.com'
version '1.0'
issues_url 'https://github.com/engineyard/ey-cookbooks-stable-v5/issues'
source_url 'https://github.com/engineyard/ey-cookbooks-stable-v5'

depends 'nginx'
depends 'haproxy'
