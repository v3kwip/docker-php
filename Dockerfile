FROM php:5-apache

# Install modules
RUN apt-get update \
    && apt-get install -y \
        git \
        pdftk \
        libcurl4-openssl-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libz-dev \
        zlib1g-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install -j$(nproc) bcmath curl gd gettext intl mbstring mysqli mcrypt opcache pdo pdo_mysql xml zip \
    && pecl install memcache && docker-php-ext-enable memcache \
    && pecl install memcached && docker-php-ext-enable memcached \
    && echo "upload_max_filesize = 200M\npost_max_size = 200M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "log_errors=On\ndisplay_errors=Off\nerror_reporting=E_ERROR | E_PARSE" > /usr/local/etc/php/conf.d/errors.ini \
    && echo 'date.timezone = UTC' >> /usr/local/etc/php/php.ini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

ENV WEBROOT /app/public
COPY scripts/start.sh /start.sh
RUN chmod a+x /start.sh
CMD ["/start.sh"]