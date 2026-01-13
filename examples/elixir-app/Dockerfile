ARG ELIXIR_VERSION=1.18.1
ARG OTP_VERSION=27.2
ARG ALPINE_VERSION=3.20.3

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION} AS builder

WORKDIR /build

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock* ./

# Install dependencies
RUN mix deps.get --only prod

# Copy application files
COPY config config
COPY lib lib
COPY rel rel

# Build release
RUN MIX_ENV=prod mix release

# Final stage
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

# Copy release from builder
COPY --from=builder /build/_build/prod/rel/elixir_app /app

# Set environment variables
ENV RELEASE_COOKIE=test_cookie_change_me \
    NODE_NAME=elixir_app \
    POD_IP=127.0.0.1

CMD ["/app/bin/elixir_app", "start"]
