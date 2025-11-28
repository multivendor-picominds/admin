FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev zlib1g-dev libonig-dev \
    build-essential zip unzip git curl

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring zip bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . /var/www

# nginx config template
COPY docker/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template

# supervisor config
COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN chown -R www-data:www-data /var/www

EXPOSE 8080

# 🔥 Generate nginx config at runtime, THEN start supervisor
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && supervisord -c /etc/supervisor/conf.d/supervisor.conf"
