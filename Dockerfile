FROM php:8.2-fpm

# Install system dependencies including nginx + envsubst
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext-base \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip unzip git curl \
    libzip-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip bcmath
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App directory
WORKDIR /var/www

# Copy app
COPY . /var/www

# Copy Nginx config (as template)
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf.template

# Replace $PORT in the template and generate actual config
RUN envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Copy Supervisor config
COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Permissions
RUN chown -R www-data:www-data /var/www && chmod -R 775 /var/www/storage

# Expose Render port (not required but helpful)
EXPOSE 8080

# Start Supervisor -> runs nginx + php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
