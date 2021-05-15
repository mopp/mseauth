defmodule MseauthTest.RepoCase do
  use ExUnit.CaseTemplate

  setup do
    alias Mseauth.Repo

    Repo.delete_all(Repo.User)

    :ok
  end
end
