defmodule Mseauth.Repo.RefreshToken do
  use Ecto.Schema

  import Ecto.Changeset

  schema "refresh_tokens" do
    field(:value, :string)
    field(:expired_at, :naive_datetime)

    timestamps()
  end
end
