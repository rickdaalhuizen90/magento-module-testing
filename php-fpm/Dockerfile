ARG PHP_VERSION=8.2
ARG COMPOSER_VERSION=2.2

FROM php:${PHP_VERSION}-fpm

RUN usermod --uid 1000 www-data
RUN groupmod --gid 1000 www-data

# Install system dependencies
RUN apt-get update && apt-get -y install \
    procps \
    git \
    zlib1g-dev \
    libzip-dev \
    openssh-client \
    mariadb-client \
    apt-transport-https \
    zip \
    jq \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libsodium-dev \
    libicu-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev

RUN set -eux; \
    \
    docker-php-ext-install \
        pdo \
        pdo_mysql \
        xsl \
        soap \
        bcmath \
        sodium \
        zip \
        intl \
        sockets \
        opcache; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j$(nproc) gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html