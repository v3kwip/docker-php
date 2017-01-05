#!/bin/bash

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
  webroot=$WEBROOT
  sed -i "s#root /app/public;#root ${webroot};#g" /etc/nginx/sites-available/default.conf
else
  webroot=/app/public
fi

# Set custom location root
if [ ! -z "$LOCATIONROOT" ]; then
  location=$LOCATIONROOT
  sed -i "s#location / {#location ${location} {#g" /etc/nginx/sites-available/default.conf
  sed -i "s#/index.php#${location}/index.php#g" /etc/nginx/sites-available/default.conf
fi

# Allow run custom script
if [ ! -z "$SCRIPT" ] && [ -f "$SCRIPT" ]; then
  chmod a+x $SCRIPT
  . $SCRIPT
fi

# Always chown webroot for better mounting
chown -Rf nginx.nginx $webroot

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
