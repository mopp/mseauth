defmodule Mseauth.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :auth_id, :string, null: false
      add :password, :string, null: false

      timestamps()
    end
    create index("users", [:auth_id], unique: true)

    create table(:access_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :expired_at, :naive_datetime, null: false # TODO: Use datetime with timezone.
      add :user_id, references("users", type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end
    create index("access_tokens", [:user_id])

    create table(:refresh_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :expired_at, :naive_datetime, null: false # TODO: Use datetime with timezone.
      add :user_id, references("users", type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end
    create index("refresh_tokens", [:user_id])
  end
end
