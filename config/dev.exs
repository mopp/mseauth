import Config

config :mseauth, Mseauth.Repo,
  database: "mseauth_dev",
  username: "mopp",
  password: "mopp123",
  hostname: "localhost",
  port: "5432"

config :libcluster,
  topologies: []

config :libring,
  rings: [
    main: [monitor_nodes: true, node_blacklist: [~r/^remsh.*$/]]
  ]
