PHP
====

This PHP recipe is used to install, configure, and eselect the specified version of PHP as well as default php.ini files. 


## Changing the installed version
If you would like to change the version of PHP installed with this recipe this can be accomplished by updateing the attributes/php.rb file.  At present modifying the version specified after the else clause on line 9 of attributes/php.rb will change the default version installed.  A change made here will update both the cli and fpm php versions.

## Changing the php.ini configuration
This recipe uses files/default/php.ini to configure the command line (/etc/php/cli-php{VERSION}/php.ini) and the php-fpm (/etc/php/fpm-php{VERSION}/php.ini) configuration files.  files/default/php.ini can be modified as desired to accomidate alternate values.
