defmodule Mseauth.Repo.AccessToken do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.User

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "access_tokens" do
    field(:expired_at, :naive_datetime)
    belongs_to(:user, User, type: Ecto.UUID)

    timestamps()
  end

  def changeset(access_token, params \\ %{}) do
    access_token
    |> cast(params, [:expired_at, :user_id])
    |> validate_required([:expired_at, :user_id])
    |> assoc_constraint(:user)
  end
end
