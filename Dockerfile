FROM ruby:2.2

RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /var/u/app/metadata
WORKDIR /var/u/app/metadata

ONBUILD COPY Gemfile /var/u/app/metadata/
ONBUILD COPY Gemfile.lock /var/u/app/metadata/
ONBUILD RUN bundle install

ONBUILD COPY . /var/u/app/metadata/

# copy in private info

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
