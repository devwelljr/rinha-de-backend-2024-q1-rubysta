FROM ruby:3.2.2

WORKDIR /app
COPY . .
RUN bundle install

CMD ["rackup", "-p", "8080", "-o", "0.0.0.0"]
