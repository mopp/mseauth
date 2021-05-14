defmodule Mseauth.Repo.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mseauth.Repo.Session

  schema "users" do
    field(:identifier, :string)
    field(:password, :string)
    has_many(:sessions, Session)

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :password])
    |> validate_required([:identifier, :password])
  end
end
