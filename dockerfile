FROM php:7.4-fpm

RUN apt-get update -y \
    && apt-get install -y nginx supervisor

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN apt-get install libicu-dev -y

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install opcache 
RUN docker-php-ext-configure intl 
RUN docker-php-ext-install intl 

RUN apt-get install libgd-dev libpng-dev libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev -y
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd
RUN docker-php-ext-enable gd

RUN apt-get install libzip-dev -y
RUN docker-php-ext-install zip 

# RUN apt-get remove libicu-dev libpng-dev libzip-dev -y

RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/php-opocache-cfg.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# PHP Error Log Files
RUN mkdir /var/log/php
RUN touch /var/log/php/errors.log && chmod 777 /var/log/php/errors.log

COPY ./.docker/entrypoint.sh /etc/entrypoint.sh
RUN sh -c 'chmod +x /etc/entrypoint.sh'

# COPY ./xpressengine /xpressengine

WORKDIR /xpressengine
# RUN composer install --optimize-autoloader --no-dev

# Copy nginx/php/supervisor configs
COPY ./.docker/supervisor.conf /etc/supervisord.conf
# nginx 추가
COPY ./.docker/nginx.conf /etc/nginx/sites-enabled/default
# php  설정 파일
COPY ./.docker/php.ini /usr/local/etc/php/php.ini

ENTRYPOINT ["/etc/entrypoint.sh"]
# ENTRYPOINT ["service php-fpm start && nginx -g "daemon off;""]
