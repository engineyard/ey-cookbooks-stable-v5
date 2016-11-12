PHP
====

This PHP recipe is used to install, configure, and eselect the specified version of PHP as well as default php.ini files. 


## Changing the installed version
When applicable the most strait forward way to change the PHP major version is to select the appropriate version via the dashboard.  This recipe will default to that selection first.  If you would like to change the minor version of PHP installed with this recipe this can be accomplished by updating the attributes/php.rb file.  A change made here will update both the cli and fpm php versions.

## Changing the php.ini configuration
This recipe uses files/default/php.ini to configure the command line (/etc/php/cli-php{VERSION}/php.ini) and the php-fpm (/etc/php/fpm-php{VERSION}/php.ini) configuration files.  files/default/php.ini can be modified as desired to accommodate alternate values.
