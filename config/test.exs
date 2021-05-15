import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth_test",
  username: "mopp",
  password: "mopp123",
  hostname: "postgres",
  port: "5432"
