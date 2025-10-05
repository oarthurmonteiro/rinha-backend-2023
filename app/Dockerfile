FROM elixir:1.18.4-otp-28-alpine AS base

RUN apk update && apk add --virtual build-dependencies build-base gcc wget git

WORKDIR /app

# install hex + rebar
RUN mix local.hex --force \
  && mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./

EXPOSE 4000


FROM base AS dev

RUN apk add inotify-tools

RUN mix deps.get

RUN mix assets.setup

COPY . .

CMD [ "mix", "phx.server" ]


FROM base AS builder


# set build ENV
ENV MIX_ENV="prod"

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# Compile the release
RUN mix compile

# compile assets
RUN mix assets.deploy

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:3.22.1 AS final

RUN apk update && apk add --no-cache libstdc++ openssl ncurses-libs musl-locales ca-certificates \
  && rm -rf /var/lib/apk/lists/*

# Set the locale
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
#   && locale-gen

# Set the locale
# RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/rinha ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
