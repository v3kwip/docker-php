FROM alpine
MAINTAINER sang@go1.com.au

ENV php_conf /etc/php5/php.ini
ENV fpm_conf /etc/php5/php-fpm.conf

# Add edge cdn
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache bash \
        openssh-client \
        rsync \
        shadow \
        supervisor \
        nginx \
        curl \
        php5 \
        php5-fpm \
        php5-bcmath \
        php5-bz2 \
        php5-calendar \
        php5-ctype \
        php5-curl \
        php5-dom \
        php5-exif \
        php5-ftp \
        php5-gettext \
        php5-gd \
        php5-iconv \
        php5-intl \
        php5-imap \
        php5-json \
        php5-mysql \
        php5-mysqli \
        php5-mcrypt \
        php5-memcache \
        php5-opcache \
        php5-openssl \
        php5-pdo \
        php5-pdo_mysql \
        php5-pdo_pgsql \
        php5-pdo_sqlite \
        php5-phar \
        php5-posix \
        php5-pgsql \
        php5-soap \
        php5-sockets \
        php5-sqlite3 \
        php5-wddx \
        php5-xml \
        php5-xmlreader \
        php5-xsl \
        php5-zip \
        php5-zlib \
        ca-certificates && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/nginx && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    rm -Rf /etc/nginx/nginx.conf && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /app/public/ && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

COPY conf/supervisord.conf /etc/supervisord.conf
# Copy our nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/app-site.conf /etc/nginx/sites-available/default.conf
COPY scripts/start.sh /start.sh

# tweak php-fpm config
RUN sed -i \
        -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" \
        -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" \
        -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" \
        -e "s/memory_limit\s*=\s*128M/memory_limit = 64M/g" \
        -e "s/max_execution_time\s*=\s*30/max_execution_time = 120"
        -e "s/;opcache.memory_consumption=64/opcache.memory_consumption=32/g" \
        -e "s/variables_order\s*=\s*\"GPCS\"/variables_order = \"EGPCS\"/g" \
        -e "s/;error_log\s*=\s*php_errors.log/error_log = \/dev\/stderr/g" \
        ${php_conf} && \
    sed -i \
        -e "s/;daemonize\s*=\s*yes/daemonize = no/g" \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 4/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/user = nobody/user = nginx/g" \
        -e "s/group = nobody/group = nginx/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = nobody/listen.owner = nginx/g" \
        -e "s/;listen.group = nobody/listen.group = nginx/g" \
        -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
        -e "s/^;clear_env = no$/clear_env = no/" \
        -e "s/^;listen.allowed_clients = 127.0.0.1$/listen.allowed_clients = 127.0.0.1/" \
        ${fpm_conf} && \
    find /etc/php5/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Add Permission Scripts
RUN chmod a+x /start.sh

EXPOSE 80
CMD ["/start.sh"]