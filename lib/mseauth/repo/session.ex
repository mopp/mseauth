defmodule Mseauth.Repo.Session do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Repo.User

  schema "sessions" do
    belongs_to(:user, User)
    belongs_to(:access_token, AccessToken)
    belongs_to(:refresh_token, RefreshToken)

    timestamps()
  end
end
