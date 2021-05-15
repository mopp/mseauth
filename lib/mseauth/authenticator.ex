defmodule Mseauth.Authenticator do
  import Ecto.Query

  alias Mseauth.Repo
  alias Mseauth.Repo.User
  alias Mseauth.Session

  def register(auth_id, password) do
    # TODO: Hash the given password.
    {:ok, _} =
      %User{auth_id: auth_id, password: password}
      |> User.changeset()
      |> Repo.insert()

    :ok
  end

  def authenticate(auth_id, password) do
    user =
      User
      |> where([user], user.auth_id == ^auth_id)
      |> where([user], user.password == ^password)
      |> select([user], user)
      |> Repo.one!()

    {:ok, {access_token, refresh_token}} = start_session(user)

    {:ok, {user.id, access_token.id, refresh_token.id}}
  end

  defp start_session(user) do
    pid =
      case Session.Supervisor.start_child(user.id) do
        {:ok, pid} ->
          pid

        {:error, {:already_started, pid}} ->
          pid
      end

    Session.Worker.start_session(pid)
  end
end
