FROM ruby:3.0.3

COPY . /code
WORKDIR /code
RUN apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && bundle

EXPOSE 3030
CMD bundle exec smashing start
