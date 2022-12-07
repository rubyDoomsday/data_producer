FROM ruby:2.7.1

WORKDIR /engine

COPY . /engine

ARG GITHUB_TOKEN

RUN script/bootstrap
