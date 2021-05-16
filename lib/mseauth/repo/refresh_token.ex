defmodule Mseauth.Repo.RefreshToken do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.User

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "refresh_tokens" do
    field(:expired_at, :naive_datetime)
    belongs_to(:user, User, type: Ecto.UUID)
    belongs_to(:access_token, AccessToken, type: Ecto.UUID)

    timestamps()
  end

  def changeset(refresh_token, params \\ %{}) do
    refresh_token
    |> cast(params, [:expired_at, :user_id, :access_token_id])
    |> validate_required([:expired_at, :user_id, :access_token_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:access_token)
  end
end
