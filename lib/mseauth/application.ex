defmodule Mseauth.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Mseauth.Repo,
      Mseauth.Session.Supervisor,
      {Plug.Cowboy, scheme: :http, plug: Mseauth.Server}
    ]

    opts = [strategy: :one_for_one, name: Mseauth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
