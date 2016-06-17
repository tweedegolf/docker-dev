FROM php:5.6.22

# Set some versions
ENV NODE_VERSION="node_4.x" \
    NPM_VERSION="3.9.*" \
    GULP_CLI_VERSION="1.2.*" \
    COMPOSER_VERSION="1.1.2" \
    POSTGRESQL_VERSION="9.4" \
    APCU_VERSION="4.0.11"

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ruby \
        ruby-dev \
        libsqlite3-dev \
        sqlite3 \
        git \
        htop \
        dnsutils \
        tmux \
        curl \
        wget \
        apt-transport-https \
        python-pip \
        nano \
        vim \
        postgresql-client-$POSTGRESQL_VERSION

# Install nodejs, update npm and install gulp-cli
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/$NODE_VERSION jessie main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nodejs
RUN npm install -g "npm@$NPM_VERSION"
RUN npm install -g "gulp-cli@$GULP_CLI_VERSION"

# Install other PHP modules
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libpng12-dev \
        postgresql-server-dev-$POSTGRESQL_VERSION \
        libxslt1-dev \
        libbz2-dev \
        libgmp-dev \
        libicu-dev \
        imagemagick \
        libmagickwand-dev \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include --with-jpeg-dir=/usr/include \
    && docker-php-ext-install -j$(nproc) \
        gd \
        opcache \
        pdo_pgsql \
        zip \
        bcmath \
        bz2 \
        calendar \
        ftp \
        gettext \
        gmp \
        intl \
        pdo_mysql \
        sockets \
        exif \
    && pecl install imagick \
    && pecl install apcu-$APCU_VERSION \
    && docker-php-ext-enable \
        imagick \
        apcu

# Install composer
RUN curl -o /usr/local/bin/composer https://getcomposer.org/download/$COMPOSER_VERSION/composer.phar \
    && chmod a+x /usr/local/bin/composer

# Install sphinx-doc
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python \
        python-dev \
        python-pip \
        libyaml-dev \
    && pip install \
        sphinx \
        sphinx-autobuild \
        sphinx-rtd-theme \
        recommonmark
