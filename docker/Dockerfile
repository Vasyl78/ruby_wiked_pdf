FROM ruby:3.2.0-slim AS build-env

ARG PROJECT_ROOT=/app
ARG BUILD_PACKAGES="build-essential curl git wkhtmltopdf"
ARG DEV_PACKAGES=""
ARG RUBY_PACKAGES="tzdata"

ENV RACK_ENV=production
ENV BUNDLE_APP_CONFIG="$PROJECT_ROOT/.bundle"
ENV LANG=C.UTF-8

WORKDIR $PROJECT_ROOT

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES \
    && apt-get clean -y

RUN gem install -N bundler

COPY Gemfile* ./
COPY Gemfile Gemfile.lock $PROJECT_ROOT/

RUN bundle config --global frozen 1 \
    && bundle install  -j4 --retry 3 --path=vendor/bundle

COPY . .