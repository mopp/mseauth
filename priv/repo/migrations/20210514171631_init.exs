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

      timestamps()
    end

    create table(:refresh_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :expired_at, :naive_datetime, null: false # TODO: Use datetime with timezone.

      timestamps()
    end

    create table(:sessions) do
      add :user_id, references("users", type: :uuid, on_delete: :delete_all)
      add :access_token_id, references("access_tokens", type: :uuid)
      add :refresh_token_id, references("refresh_tokens", type: :uuid)

      timestamps()
    end
    create index("sessions", [:user_id])
    create index("sessions", [:access_token_id])
    create index("sessions", [:refresh_token_id])
  end
end
