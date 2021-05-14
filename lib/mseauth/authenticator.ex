defmodule Mseauth.Authenticator do
  alias Mseauth.Repo.User
  alias Mseauth.Repo

  def register(identifier, password) do
    # TODO: Hash the given password.
    {:ok, _} =
      %User{identifier: identifier, password: password}
      |> User.changeset()
      |> Repo.insert()

    :ok
  end
end
