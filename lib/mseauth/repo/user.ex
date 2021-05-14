defmodule Mseauth.Repo.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:identifier, :string)
    field(:password, :string)
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :password])
    |> validate_required([:identifier, :password])
  end
end
