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
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y xvfb iceweasel

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
ENV DISPLAY :99
# Need to have a rake :ci task in your rakefile
ENTRYPOINT /etc/init.d/xvfd start \
    && rake ci

