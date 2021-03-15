FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y nodejs
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY db.csv /myapp/db.csv
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp


CMD bundle exec unicorn -c config/unicorn.rb

