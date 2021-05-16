# Mseauth

Authentication and distributed session management.

## How to run

```console
mix deps.get
mix compile
iex -S mix
```

## How to run with cluster.

```console
> docker-compose build
> docker-compose run --rm --service-ports mseauth1 mix release --overwrite
> docker-compose up

> curl -X POST -H "Content-Type: application/json" http://0.0.0.0:8080/register -d '{"identifier": "mopp", "password": "lgtm"}'
{"status":"succeeded"}%

> curl -X POST -H "Content-Type: application/json" http://0.0.0.0:8080/authenticate -d '{"identifier": "mopp", "password": "lgtm"}'
{"access_token":{"expired_at":"2021-05-16T16:58:04","value":"77a2c4a3-48f9-421a-ab2c-87cfafc3690f"},"identifier":"f87bd5f4-bf1b-467c-a515-b6678dc9be25","refresh
_token":{"expired_at":"2021-05-16T18:58:04","value":"c22cd5bf-bf18-49d4-8999-2b4494b227bf"},"status":"succeeded"}%

> curl -X POST -H "Content-Type: application/json" http://0.0.0.0:8080/validate -d '{"access_token": "77a2c4a3-48f9-421a-ab2c-87cfafc3690f"}'
{"identifier":"f87bd5f4-bf1b-467c-a515-b6678dc9be25","status":"succeeded"}%
```

Clean up the database.
```console
> docker-compose run --rm --service-ports mseauth1 mix ecto.drop
> docker-compose run --rm --service-ports mseauth1 mix ecto.create
```

## How to test

```console
> docker-compose up -d postgres
> MIX_ENV=test mix ecto.create
> mix test
```
