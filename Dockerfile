FROM elixir:1.11.4

WORKDIR /mseauth

RUN mix local.hex --force
RUN mix local.rebar --force

CMD ["/mseauth/_build/local/rel/mseauth/bin/mseauth", "start"]
