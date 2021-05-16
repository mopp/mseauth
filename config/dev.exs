import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth_local",
  username: "mopp",
  password: "mopp123",
  hostname: "localhost",
  port: "5432"

config :libcluster,
  topologies: []
