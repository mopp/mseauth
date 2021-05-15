defmodule Mseauth.Repo.RefreshToken do
  use Ecto.Schema

  # import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  schema "refresh_tokens" do
    field(:expired_at, :naive_datetime)

    timestamps()
  end
end
