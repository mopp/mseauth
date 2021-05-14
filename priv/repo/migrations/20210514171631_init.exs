defmodule Mseauth.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :identifier, :string
      add :password, :string

      timestamps()
    end
    create index("users", [:identifier], unique: true)

    create table(:tokens) do
      add :user_identifier, references("users", type: :string, column: :identifier, on_delete: :delete_all)
      add :access_token, :string
      add :refresh_token, :string

      timestamps()
    end
    create index("tokens", [:user_identifier])
  end
end
