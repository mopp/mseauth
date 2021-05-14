import Config

config :mseauth, ecto_repos: [Mseauth.Repo]

import_config "#{config_env()}.exs"
