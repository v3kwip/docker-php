#!/bin/bash

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
  webroot=$WEBROOT
  sed -i "s#DocumentRoot /var/www/html#DocumentRoot ${webroot}#g" /etc/apache2/sites-available/000-default.conf
else
  webroot=/app/public
fi

sed -i "s#Directory /var/www/#Directory ${WEBROOT}/#g" /etc/apache2/apache2.conf
sed -i "s#Directory /var/www/#Directory ${WEBROOT}/#g" /etc/apache2/conf-available/docker-php.conf

# Allow run custom script
if [ ! -z "$SCRIPT" ] && [ -f "$SCRIPT" ]; then
  chmod a+x $SCRIPT
  . $SCRIPT
fi

# Always chown webroot for better mounting
chown -Rf www-data.www-data $webroot

apache2-foreground