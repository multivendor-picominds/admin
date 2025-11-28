# -------------------------
# 1. Base PHP-FPM image
# -------------------------
FROM php:8.2-fpm

# -------------------------
# 2. Install system dependencies
# -------------------------
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    librsvg2-bin && \
    rm -rf /var/lib/apt/lists/*

# -------------------------
# 3. Install PHP extensions
# -------------------------
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# -------------------------
# 4. Install Composer
# -------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -------------------------
# 5. Set working directory
# -------------------------
WORKDIR /var/www

# -------------------------
# 6. Copy app files
# -------------------------
COPY . /var/www

# -------------------------
# 7. NGINX configuration for Render
# -------------------------
RUN rm /etc/nginx/sites-enabled/default

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Ensure Render $PORT works
RUN sed -i 's/listen 80;/listen ${PORT};/' /etc/nginx/conf.d/default.conf

# -------------------------
# 8. Supervisor to run both nginx + php-fpm
# -------------------------
COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# -------------------------
# 9. Permissions
# -------------------------
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage

# -------------------------
# 10. Expose port for Render
# -------------------------
EXPOSE 8080

# -------------------------
# 11. Start supervisor (nginx + fpm)
# -------------------------
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
