FROM ruby:2.2.3
MAINTAINER Dylan Grafmyre <dylan@shakacode.com>

# Install build-essential, node, and npm
RUN apt-get update && apt-get install -y build-essential
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

RUN mkdir -p /linting
WORKDIR /linting/

# Install xvfd and iceweasel/firefox for browser testing
RUN apt-get install -y xserver-common libgl1-mesa-glx libxfont1 libxshmfence1
RUN curl -O http://http.us.debian.org/debian/pool/main/x/xorg-server/xvfb_1.16.4-1_amd64.deb \
    && dpkg -i xvfb_1.16.4-1_amd64.deb \
    && rm xvfb_1.16.4-1_amd64.deb
RUN apt-get install -y iceweasel

COPY ["xvfd", "/etc/init.d/"]
COPY ["xvfd.conf", "/etc/init/"]

# Setup container for bundle and npm install
COPY ["package.json", "npm-shrinkwrap.json", "/linting/"]
COPY ["Gemfile", "Gemfile.lock", "/linting/"]
RUN gem install bundler \
    && bundle install --jobs 4
RUN npm install
ENV PATH /linting/node_modules/.bin:$PATH

# Start xvfd server at container runtime
ENTRYPOINT service xvfd start && bash
