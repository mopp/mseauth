defmodule Mseauth.Authenticator do
  import Ecto.Query

  alias Mseauth.Repo
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.Session
  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Repo.User

  def register(auth_id, password) do
    # TODO: Hash the given password.
    {:ok, _} =
      %User{auth_id: auth_id, password: password}
      |> User.changeset()
      |> Repo.insert()

    :ok
  end

  def validate(auth_id, password) do
    user =
      User
      |> where([user], user.auth_id == ^auth_id)
      |> where([user], user.password == ^password)
      |> select([user], user)
      |> Repo.one!()

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

      %Session{
        user_id: user.id,
        access_token_id: access_token.id,
        refresh_token_id: refresh_token.id
      }
      |> Session.changeset()
      |> Repo.insert!()

      {user.id, access_token.id, refresh_token.id}
    end)
  end
end
