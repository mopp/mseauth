defmodule Mseauth.Authenticator do
  import Ecto.Query

  alias Mseauth.Repo
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Repo.User

  def register(identifier, password) do
    # TODO: Hash the given password.
    {:ok, _} =
      %User{identifier: identifier, password: password}
      |> User.changeset()
      |> Repo.insert()

    :ok
  end

  def validate(identifier, password) do
    user =
      User
      |> where([user], user.identifier == ^identifier)
      |> where([user], user.password == ^password)
      |> select([user], user)
      |> Repo.one!()

    {:ok, access_token} =
      %AccessToken{
        value: gen_random_string(),
        expired_at:
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(120 * 60)
          |> NaiveDateTime.truncate(:second)
      }
      |> Repo.insert()

    {:ok, refresh_token} =
      %RefreshToken{
        value: gen_random_string(),
        expired_at:
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(240 * 60)
          |> NaiveDateTime.truncate(:second)
      }
      |> Repo.insert()

    Ecto.build_assoc(user, :sessions, %{access_token: access_token, refresh_token: refresh_token})
    |> Repo.insert()

    {:ok, {user.identifier, access_token.value, refresh_token.value}}
  end

  defp gen_random_string do
    # FIXME
    symbols = '0123456789abcdef'
    symbol_count = Enum.count(symbols)
    for _ <- 1..10, into: "", do: <<Enum.at(symbols, :crypto.rand_uniform(0, symbol_count))>>
  end
end
