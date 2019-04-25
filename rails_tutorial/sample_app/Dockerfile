FROM ruby:2.6.2
RUN apt-get update -qq && apt-get install -y nodejs sqlite3

ENV APP_ROOT /sample_app

RUN mkdir /${APP_ROOT}
WORKDIR /${APP_ROOT}
COPY Gemfile /${APP_ROOT}/Gemfile
COPY Gemfile.lock /${APP_ROOT}/Gemfile.lock
RUN bundle install
COPY . /${APP_ROOT}

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]