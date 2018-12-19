name 'custom-ec2-balances-monitoring'
description 'Monitoring of EC2 CPU credits and IOPS burst credits.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
maintainer 'Engine Yard'
maintainer_email 'support@engineyard.com'
version '1.0.0'
issues_url 'https://github.com/engineyard/ey-cookbooks-stable-v5/issues'
source_url 'https://github.com/engineyard/ey-cookbooks-stable-v5'

depends 'collectd'
