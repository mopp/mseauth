defmodule Mseauth.Application do
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      Mseauth.Repo,
      {Plug.Cowboy, scheme: :http, plug: Mseauth.Server},
      {DynamicSupervisor, strategy: :one_for_one, name: Mseauth.SessionSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Mseauth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
