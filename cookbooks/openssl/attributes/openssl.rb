default.openssl.using_metadata = !!node.engineyard.metadata("openssl_ebuild_version",nil)
# YT-CC-1146
default.openssl.version = node.engineyard.metadata('openssl_ebuild_version','1.0.2k')
