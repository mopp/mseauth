FROM elixir:1.11.4

WORKDIR /mseauth

ADD . /mseauth

RUN apt-get update
RUN apt-get upgrade --yes
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
RUN mix release --force --overwrite

CMD ["/mseauth/_build/dev/rel/mseauth/bin/mseauth", "start"]
