FROM ubuntu:xenial

MAINTAINER Peter Evans <pete.evans@gmail.com>

ENV NOMINATIM_VERSION 3.0.1

# Let the container know that there is no TTY
ARG DEBIAN_FRONTEND=noninteractive

# Set locale
ENV LANG C.UTF-8
RUN apt-get -y update \
 && apt-get install -y -qq --no-install-recommends locales \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

# Install packages
RUN apt-get -y update \
 && apt-get install -y -qq --no-install-recommends \
    build-essential \
    cmake \
    g++ \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libexpat1-dev \
    zlib1g-dev \
    libxml2-dev \
    libbz2-dev \
    libpq-dev \
    libgeos-dev \
    libgeos++-dev \
    libproj-dev \
    postgresql-server-dev-9.5 \
    postgresql-9.5-postgis-2.2 \
    postgresql-contrib-9.5 \
    apache2 \
    php \
    php-pgsql \
    libapache2-mod-php \
    php-pear \
    php-db \
    php-intl \
    curl \
    sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/*

# Build Nominatim
RUN cd /srv \
 && curl --silent -L http://www.nominatim.org/release/Nominatim-$NOMINATIM_VERSION.tar.bz2 -o v$NOMINATIM_VERSION.tar.bz2 \
 && tar xf v$NOMINATIM_VERSION.tar.bz2 \
 && rm v$NOMINATIM_VERSION.tar.bz2 \
 && mv Nominatim-$NOMINATIM_VERSION nominatim \
 && cd nominatim \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make

# Configure Nominatim
COPY local.php /srv/nominatim/build/settings/local.php

# Configure Apache
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Allow remote connections to PostgreSQL
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf \
 && echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Set the entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
EXPOSE 8080
