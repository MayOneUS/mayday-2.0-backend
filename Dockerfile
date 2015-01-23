# Dockerfile for Mayone-2.0 Rails project

FROM ruby:2.2-onbuild

MAINTAINER andrew.tork.baker@gmail.com

CMD ["./bin/rails", "server"]
