defmodule Mseauth.Repo.Session do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.User

  schema "sessions" do
    belongs_to(:user, User, type: Ecto.UUID)
    belongs_to(:access_token, AccessToken, type: Ecto.UUID)
    belongs_to(:refresh_token, RefreshToken, type: Ecto.UUID)

    timestamps()
  end

  def changeset(session, params \\ %{}) do
    session
    |> cast(params, [:user_id, :access_token_id, :refresh_token_id])
    |> validate_required([:user_id, :access_token_id, :refresh_token_id])
  end
end
