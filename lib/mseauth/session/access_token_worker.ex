defmodule Mseauth.Session.AccessTokenWorker do
  use GenServer

  def start(access_token) do
    Node.spawn(Node.self(), fn ->
      GenServer.start(__MODULE__, access_token, name: {:global, access_token.id})
    end)
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
