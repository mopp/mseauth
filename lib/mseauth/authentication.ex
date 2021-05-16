defmodule Mseauth.Authentication do
  import Ecto.Query

  alias Mseauth.Repo
  alias Mseauth.Repo.User

  def register(auth_id, password) do
    # TODO: Hash the given password.
    {:ok, _} =
      %User{auth_id: auth_id, password: password}
      |> User.changeset()
      |> Repo.insert()

    :ok
  end

  def authenticate(auth_id, password) do
    User
    |> where([user], user.auth_id == ^auth_id)
    |> where([user], user.password == ^password)
    |> select([user], user)
    |> Repo.one()
  end

  def change_password(auth_id, old_password, new_password) do
    # TODO: Implement.
    :ok
  end

  def withdraw(auth_id, password) do
    # TODO: Implement.
    :ok
  end
end
