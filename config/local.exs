import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth_local",
  username: "mopp",
  password: "mopp123",
  hostname: "postgres",
  port: "5432"

config :libcluster,
  topologies: [
    default: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [:alpha@mseauth1, :bravo@mseauth2, :charlie@mseauth3]]
    ]
  ]

config :libring,
  rings: [
    main: [monitor_nodes: true, node_blacklist: [~r/^remsh.*$/]]
  ]
