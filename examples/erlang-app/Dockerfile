ARG OTP_VERSION=27.2
ARG ALPINE_VERSION=3.20.3

FROM erlang:${OTP_VERSION}-alpine AS builder

WORKDIR /build

# Install rebar3
RUN apk add --no-cache git && \
    wget https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && \
    mv rebar3 /usr/local/bin/

# Copy application files
COPY . .

# Build release
RUN rebar3 release

# Final stage
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

# Copy release from builder
COPY --from=builder /build/_build/default/rel/erlang_app /app

# Set environment variables
ENV RELEASE_COOKIE=test_cookie_change_me \
    NODE_NAME=erlang_app \
    POD_IP=127.0.0.1

CMD ["/app/bin/erlang_app", "foreground"]
