defmodule Mseauth.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :identifier, :string
      add :password, :string

      timestamps()
    end
    create index("users", [:identifier], unique: true)

    create table(:access_tokens) do
      add :value, :string
      add :expired_at, :naive_datetime # TODO: Use datetime with timezone.

      timestamps()
    end
    create index("access_tokens", [:value], unique: true)

    create table(:refresh_tokens) do
      add :value, :string
      add :expired_at, :naive_datetime # TODO: Use datetime with timezone.

      timestamps()
    end
    create index("refresh_tokens", [:value], unique: true)

    create table(:sessions) do
      add :user_id, references("users", on_delete: :delete_all)
      add :access_token_id, references("access_tokens")
      add :refresh_token_id, references("refresh_tokens")

      timestamps()
    end
    create index("sessions", [:user_id])
  end
end
