defmodule Mseauth.Session do
  import Ecto.Query

  use GenServer

  alias Mseauth.Repo
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken

  def start(user) do
    {access_token, refresh_token, session} = create_session(user.id)

    {:ok, {access_token, refresh_token}}
    # {:ok, pid} = Session.RefreshTokenWorker.start(refresh_token)
    # {:ok, pid} = Session.AccessTokenWorker.start(refresh_token, pid)

    # TODO: Return expired_at for each token.

    # create refresh token and spawn corresponding process.
    #   - spawn access token process.
    # return access_token and refresh_token with their expired_at.
  end

  def validate(access_token) do
    # if process_exists do
    #   check expired_at
    # else
    #   read db
    #   spawn process
    #   check expired_at
    #   if expired do
    #     exit and false
    #   else
    #     true
    #   end
    # end
    # Session.AccessTokenWorker.validate(access_token)
    {:ok, "identifier"}
  end

  def refresh(refresh_token) do
    # if process_exists do
    #   # kill old access_token
    #   # create_new_access_token
    # else
    #   read db
    #   spawn process
    #   check expired_at
    #   if expired do
    #     exit and false
    #   else
    #     create_new_access_token
    #   end
    # end
    # Session.RefreshTokenWorker.refresh(refresh_token)
    {:ok, "access_token"}
  end

  def expire(access_token) do
    # remove them from DB.
    # kill refresh_token (and access_token) processes
    :ok
  end

  defp create_session(user_id) do
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
        |> Repo.Session.changeset()
        |> Repo.insert!()

      {access_token, refresh_token, session}
    end)
  end
end
