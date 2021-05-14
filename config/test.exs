import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth_test",
  username: "mopp",
  password: "mopp123",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
