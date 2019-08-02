# Container Base
FROM php:7.1-apache

ENV http_proxy ${HTTP_PROXY}
ENV https_proxy ${HTTP_PROXY}
ENV NR_APP_NAME=""
ENV NR_LICENSE_KEY=""
ENV LD_LIBRARY_PATH /opt/oci8/instantclient_12_1/
ENV XDEBUG_ENABLED=true

COPY configs/ports.conf /etc/apache2/ports.conf
COPY configs/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache-run.sh /usr/bin/apache-run

RUN chmod a+x /usr/bin/apache-run

# Install libs
RUN apt-get update && apt-get install -y wget vim zip libfreetype6-dev libjpeg62-turbo-dev \
       libmcrypt-dev libpng-dev libssl-dev libaio1 git libcurl4-openssl-dev libxslt-dev \
       libldap2-dev libicu-dev libc-client-dev libkrb5-dev libsqlite3-dev libedit-dev libpq-dev libxrender1 libfontconfig1 \
       unixodbc-dev mssql-tools

RUN a2enmod rewrite

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) iconv bcmath mcrypt \
        gd pdo_mysql pdo_pgsql calendar curl exif ftp gettext \
        hash xsl ldap intl imap pdo_sqlite mbstring \
        mcrypt pcntl readline shmop soap sockets wddx zip

# Install oci8
RUN mkdir -p /opt/oci8
COPY instantclient-basic-linux.x64-12.1.0.2.0.zip /opt/oci8
COPY instantclient-sdk-linux.x64-12.1.0.2.0.zip /opt/oci8
RUN cd /opt/oci8 \
    && unzip instantclient-sdk-linux.x64-12.1.0.2.0.zip \
    && unzip instantclient-basic-linux.x64-12.1.0.2.0.zip \
    && cd instantclient_12_1/ \
    && ln -s libclntsh.so.12.1 libclntsh.so \
    && ln -s libocci.so.12.1 libocci.so \
    && cd /tmp \
    && wget https://pecl.php.net/get/oci8-2.1.7.tgz \
    && tar xzf oci8-2.1.7.tgz \
    && cd oci8-2.1.7 \
    && phpize \
    && ./configure --with-oci8=shared,instantclient,/opt/oci8/instantclient_12_1/ \
    && make \
    && make install \
    && echo "extension=/tmp/oci8-2.1.7/modules/oci8.so" >> /usr/local/etc/php/conf.d/oci8.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

RUN pecl install sqlsrv \
    pdo_sqlsrv

RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

# Install XDebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

CMD /usr/bin/apache-run

EXPOSE 8080
