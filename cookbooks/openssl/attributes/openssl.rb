default.openssl.using_metadata = !!node.engineyard.metadata("openssl_ebuild_version",nil)

# Openssl version updated from 1.0.2k to 1.0.2r
# YT-CC-1266
# FB-655
default.openssl.version = node.engineyard.metadata('openssl_ebuild_version','1.0.2t')
