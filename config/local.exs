import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth",
  username: "mopp",
  password: "mopp123",
  hostname: "postgres",
  port: "5432"

config :libcluster,
  topologies: [
    default: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [:alpha@mseauth, :bravo@mseauth, :charlie@mseauth]]
    ]
  ]
