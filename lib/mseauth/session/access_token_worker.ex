defmodule Mseauth.Session.AccessTokenWorker do
  use GenServer

  alias Mseauth.Session

  def start(access_token) do
    node = HashRing.Managed.key_to_node(:main, access_token.id)

    Node.spawn(node, fn ->
      Session.Supervisor.start_child(__MODULE__, access_token)
    end)
  end

  def start_link(access_token) do
    GenServer.start(__MODULE__, access_token, name: {:global, access_token.id})
  end

  def fetch(access_token_id) do
    case GenServer.whereis({:global, access_token_id}) do
      nil ->
        nil

      pid ->
        GenServer.call(pid, :fetch)
    end
  end

  def expire(access_token_id) do
    case GenServer.whereis({:global, access_token_id}) do
      nil ->
        :ok

      pid ->
        GenServer.stop(pid, {:shutdown, :expire})
    end
  end

  @impl GenServer
  def init(access_token) do
    {:ok, access_token}
  end

  @impl GenServer
  def handle_call(:fetch, _from, access_token = state) do
    {:reply, access_token, state}
  end
end
