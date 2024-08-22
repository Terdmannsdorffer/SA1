# Stage 1: Build the application
FROM elixir:1.14-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm

# Set the working directory
WORKDIR /app

# Copy the mix.exs and mix.lock files
COPY mix.exs mix.lock ./

# Install Elixir and Phoenix dependencies
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

# Copy the rest of the application code
COPY . .

# Fetch dependencies again to ensure the lock file is up-to-date
RUN mix deps.get --only prod

# Install npm dependencies and build assets
RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN mix assets.deploy

# Digest static assets
RUN MIX_ENV=prod mix phx.digest

# Build the release
RUN MIX_ENV=prod mix release

# Stage 2: Create a minimal image for running the application
FROM alpine:3.17 AS app

RUN apk add --no-cache libssl1.1 ncurses-libs inotify-tools

# Install Elixir
RUN apk add --no-cache elixir git && \
    mix local.hex --force && \
    mix local.rebar --force

# Set environment variables
ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true
ENV APP_NAME=goodreads
ENV DATABASE_URL=ecto://postgres:1234@db/goodreads_dev
ENV SECRET_KEY_BASE=5nx5fKQAMVUJz/HPujWl6CgZuKjI2Fng7+5fXQdwNGzRoQSvAhTz3DFRN68K1Jpc

# Copy the release from the build stage
COPY --from=build /app/_build/prod/rel/${APP_NAME} /app

# Set the working directory
WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose the port the application will run on
EXPOSE 4000

# Start the Phoenix server
CMD ["sh", "/app/entrypoint.sh"]
