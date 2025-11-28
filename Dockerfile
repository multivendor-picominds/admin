FROM php:8.2-fpm

# Install required libraries for PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    zlib1g-dev \
    zip unzip git curl

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring zip bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . /var/www

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN chown -R www-data:www-data /var/www

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
