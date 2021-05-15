defmodule Mseauth.Session.Supervisor do
  use DynamicSupervisor

  alias Mseauth.Session.Worker

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(user_id) do
    DynamicSupervisor.start_child(__MODULE__, {Worker, user_id})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
