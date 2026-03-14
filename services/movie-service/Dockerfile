# services/user_service/Dockerfile
FROM ruby:3.3-alpine

RUN apk add --no-cache build-base postgresql-dev nodejs yarn tzdata

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]