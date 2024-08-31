FROM php:8.3-fpm-alpine3.19

RUN docker-php-ext-install pdo_mysql

COPY ./docker/php-fpm/conf/php-fpm.d /usr/local/etc/php-fpm.d
COPY ./src /var/www/html

