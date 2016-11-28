FROM php:5-apache

# Install modules
RUN a2enmod rewrite \
    && apt-get update \
    && apt-get install -y libpng12-dev libjpeg-dev libpq-dev git libmcrypt-dev libicu-dev libmemcached-dev libz-dev libxml2-dev libssl-dev libcurl4-openssl-dev zlib1g-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install -j$(nproc) bcmath curl gd gettext intl mbstring mcrypt opcache pdo pdo_mysql xml zip \
    && pecl install memcache && docker-php-ext-enable memcache \
    && pecl install memcached && docker-php-ext-enable memcached \
    && echo "upload_max_filesize = 200M\npost_max_size = 200M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "log_errors=On\ndisplay_errors=Off\nerror_reporting=E_ERROR | E_PARSE" > /usr/local/etc/php/conf.d/errors.ini \
    && echo 'date.timezone = UTC' >> /usr/local/etc/php/php.ini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV WEBROOT /app/public
COPY scripts/start.sh /start.sh
RUN chmod a+x /start.sh
CMD ["/start.sh"]