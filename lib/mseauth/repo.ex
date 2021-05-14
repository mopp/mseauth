defmodule Mseauth.Repo do
  use Ecto.Repo,
    otp_app: :mseauth,
    adapter: Ecto.Adapters.Postgres
end
