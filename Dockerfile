FROM ruby:2.6.8

# Install Javascript runtime
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get -y install nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 user \
    && useradd --uid 1000 --gid user --shell /bin/bash --create-home user

RUN mkdir -p /app \
    && chown user -R /app

WORKDIR /app
USER user

ENV RAILS_ENV="docker"

COPY --chown=1000:1000 Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.3.22 \
    && bundle install

COPY --chown=1000:1000 . /app
