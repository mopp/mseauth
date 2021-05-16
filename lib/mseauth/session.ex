defmodule Mseauth.Session do
  import Ecto.Query

  alias Mseauth.Repo
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Session.AccessTokenWorker

  def start(user) do
    {:ok, {access_token, refresh_token}} =
      Repo.transaction(fn ->
        {:ok, access_token} =
          %AccessToken{
            user_id: user.id,
            expired_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(120 * 60)
              |> NaiveDateTime.truncate(:second)
          }
          |> AccessToken.changeset()
          |> Repo.insert()

        {:ok, refresh_token} =
          %RefreshToken{
            user_id: user.id,
            access_token_id: access_token.id,
            expired_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(240 * 60)
              |> NaiveDateTime.truncate(:second)
          }
          |> RefreshToken.changeset()
          |> Repo.insert()

        {access_token, refresh_token}
      end)

    _pid = AccessTokenWorker.start(access_token)

    {:ok, {access_token, refresh_token}}
  end

  def validate(access_token_id) do
    case AccessTokenWorker.fetch(access_token_id) do
      nil ->
        case AccessToken
             |> where([access_token], access_token.id == ^access_token_id)
             |> select([access_token], access_token)
             |> Repo.one() do
          nil ->
            {:error, :not_found}

          access_token ->
            if NaiveDateTime.compare(NaiveDateTime.utc_now(), access_token.expired_at) == :lt do
              AccessTokenWorker.start(access_token)
              {:ok, access_token.user_id}
            else
              {:error, :expired}
            end
        end

      access_token ->
        if NaiveDateTime.compare(NaiveDateTime.utc_now(), access_token.expired_at) == :lt do
          {:ok, access_token.user_id}
        else
          AccessTokenWorker.expire(access_token_id)
          {:error, :expired}
        end
    end
  end

  def refresh(refresh_token_id) do
    case RefreshToken
         |> where([refresh_token], refresh_token.id == ^refresh_token_id)
         |> select([refresh_token], refresh_token)
         |> preload(:access_token)
         |> Repo.one() do
      nil ->
        {:error, :not_found}

      refresh_token ->
        if NaiveDateTime.compare(NaiveDateTime.utc_now(), refresh_token.expired_at) == :lt do
          {:ok, new_access_token} =
            Repo.transaction(fn ->
              # Expire old access token.
              if NaiveDateTime.compare(
                   NaiveDateTime.utc_now(),
                   refresh_token.access_token.expired_at
                 ) == :lt do
                {:ok, _} =
                  refresh_token.access_token
                  |> AccessToken.changeset(%{expired_at: NaiveDateTime.utc_now()})
                  |> Repo.update()
              end

              # Create new access token.
              {:ok, new_access_token} =
                %AccessToken{
                  user_id: refresh_token.user_id,
                  expired_at:
                    NaiveDateTime.utc_now()
                    |> NaiveDateTime.add(120 * 60)
                    |> NaiveDateTime.truncate(:second)
                }
                |> AccessToken.changeset()
                |> Repo.insert()

              new_access_token
            end)

          :ok = AccessTokenWorker.expire(refresh_token.access_token_id)
          _pid = AccessTokenWorker.start(new_access_token)

          {:ok, new_access_token}
        else
          {:error, :expired}
        end
    end
  end

  def expire(refresh_token_id) do
    case RefreshToken
         |> where([refresh_token], refresh_token.id == ^refresh_token_id)
         |> select([refresh_token], refresh_token)
         |> preload(:access_token)
         |> Repo.one() do
      nil ->
        # Corresponding refresh token does not exists
        :ok

      refresh_token ->
        if NaiveDateTime.compare(refresh_token.expired_at, NaiveDateTime.utc_now()) == :lt do
          {:ok, :ok} =
            Repo.transaction(fn ->
              {:ok, _} =
                refresh_token.access_token
                |> AccessToken.changeset(%{expired_at: NaiveDateTime.utc_now()})
                |> Repo.update()

              {:ok, _} =
                refresh_token
                |> RefreshToken.changeset(%{expired_at: NaiveDateTime.utc_now()})
                |> Repo.update()

              :ok
            end)

          :ok
        else
          :ok
        end
    end
  end
end
