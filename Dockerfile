FROM elixir:latest

RUN apt-get update
RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /mseauth

CMD iex -S mix
