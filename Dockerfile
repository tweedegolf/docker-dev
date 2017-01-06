FROM tweedegolf/php-fpm:5.6.29

# Set some versions
ENV NODE_VERSION="node_4.x" \
    NPM_VERSION="3.10.*" \
    GULP_CLI_VERSION="1.2.*" \
    COMPOSER_VERSION="1.3.0"

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ruby \
        ruby-dev \
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
        postgresql-client-9.5

# Install nodejs, update npm and install gulp-cli
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/$NODE_VERSION jessie main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        nodejs
# Fix bug https://github.com/npm/npm/issues/9863
RUN cd $(npm root -g)/npm \
    && npm install fs-extra \
    && sed -i -e s/graceful-fs/fs-extra/ -e s/fs\.rename/fs.move/ ./lib/utils/rename.js
RUN npm install -g "npm@$NPM_VERSION"
RUN npm install -g "gulp-cli@$GULP_CLI_VERSION"

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
