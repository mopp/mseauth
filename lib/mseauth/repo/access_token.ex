defmodule Mseauth.Repo.AccessToken do
  use Ecto.Schema

  import Ecto.Changeset

  schema "access_tokens" do
    field(:value, :string)
    field(:expired_at, :naive_datetime)

    timestamps()
  end
end
