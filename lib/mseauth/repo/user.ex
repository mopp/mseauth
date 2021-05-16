defmodule Mseauth.Repo.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "users" do
    field(:auth_id, :string)
    field(:password, :string)
    has_many(:access_tokens, AccessToken)
    has_many(:refresh_tokens, RefreshToken)

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:auth_id, :password])
    |> validate_required([:auth_id, :password])
  end
end
