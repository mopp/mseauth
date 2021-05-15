defmodule Mseauth.Session.Worker do
  import Ecto.Query

  use GenServer

  alias Mseauth.Repo
  alias Mseauth.Repo.Session
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken

  def start_link(user_id) do
    # TODO: change process name registry for clustering.
    GenServer.start_link(__MODULE__, user_id, name: {:global, user_id})
  end

  def start_session(pid) do
    GenServer.call(pid, :start_session)
  end

  @impl GenServer
  def init(user_id) do
    {:ok, %{user_id: user_id}, {:continue, nil}}
  end

  @impl GenServer
  def handle_continue(_, %{user_id: user_id} = state) do
    sessions =
      Session
      |> where([session], session.user_id == ^user_id)
      |> select([user], user)
      |> Repo.all(preload: [AccessToken, RefreshToken])

    # TODO: Shutdown after few minutes automatically.

    {:noreply, Map.put(state, :sessions, sessions)}
  end

  @impl GenServer
  def handle_call(:start_session, _from, %{user_id: user_id} = state) do
    {:ok, {access_token, refresh_token, session}} = create_session(user_id)

    state = %{state | sessions: [session | state[:sessions]]}

    {:reply, {:ok, {access_token, refresh_token}}, state}
  end

  def create_session(user_id) do
    Repo.transaction(fn ->
      {:ok, access_token} =
        %AccessToken{
          expired_at:
            NaiveDateTime.utc_now()
            |> NaiveDateTime.add(120 * 60)
            |> NaiveDateTime.truncate(:second)
        }
        |> Repo.insert()

      {:ok, refresh_token} =
        %RefreshToken{
          expired_at:
            NaiveDateTime.utc_now()
            |> NaiveDateTime.add(240 * 60)
            |> NaiveDateTime.truncate(:second)
        }
        |> Repo.insert()

      session =
        %Repo.Session{
          user_id: user_id,
          access_token_id: access_token.id,
          refresh_token_id: refresh_token.id
        }
        |> Session.changeset()
        |> Repo.insert!()

      {access_token, refresh_token, session}
    end)
  end
end
