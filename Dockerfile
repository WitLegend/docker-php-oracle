FROM phpdockerio/php73-fpm:latest
WORKDIR "/application"

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

COPY oci8-2.2.0.tgz /usr/packages/
COPY *.deb /usr/packages/

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install  php7.3-mysql php-redis php7.3-gd php-imagick php7.3-soap php7.3-odbc

# install oci8
RUN apt-get install -y --no-install-recommends php7.3-dev vim \
    && apt-get install -y libaio-dev make\
    && dpkg -i /usr/packages/*.deb \
    && rm -rf /usr/packages/*.deb \
    && ldconfig

RUN cd /usr/packages/ \
    && tar xzvf oci8-2.2.0.tgz \
    && rm -rf *.tgz \
    && cd /usr/packages/oci8-2.2.0 \
    && /usr/bin/phpize \
    && ./configure --with-php-config=/usr/bin/php-config --with-oci8=shared,instantclient,/usr/lib/oracle/19.6/client64/lib \
    && make \
    && make install \
    && echo 'extension=oci8' >> /etc/php/7.3/cli/php.ini \
    && echo 'extension=oci8' >> /etc/php/7.3/fpm/php.ini

# install cron supervisor
RUN apt-get install -y --no-install-recommends cron supervisor

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
