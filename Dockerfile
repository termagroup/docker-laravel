FROM php:7.1-apache

RUN apt-get update && apt-get install --no-install-recommends  -y \
    wget \
    libicu-dev \
    libssl-dev \
    libxml2-dev \
    php-soap \
    vim \
    libfreetype6-dev \
    libpng12-dev \
    libjpeg-dev

#PHP Extensions
RUN pecl install xdebug && docker-php-ext-enable xdebug \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring zip bcmath intl exif fileinfo soap \
  && docker-php-ext-enable opcache \
  && pecl install mongodb && docker-php-ext-enable mongodb

#Set the timezone.
RUN echo "Europe/Warsaw" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

#XDEBUG
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini
RUN echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/php.ini
RUN echo "xdebug.profiler_output_dir=/tmp/xdebug" >> /usr/local/etc/php/php.ini

RUN echo "pcre.jit=0" >> /usr/local/etc/php/php.ini

RUN a2enmod rewrite

#COMPOSER
RUN wget https://getcomposer.org/download/1.4.1/composer.phar -O /usr/bin/composer && chmod +x /usr/bin/composer
RUN mkdir /composer

# SET APACHE DOCUMENT ROOT
ENV DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get clean && rm -rf /vsar/lib/apt/lists/* /tmp/* /var/tmp/*
