defmodule MseauthTest.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Mseauth.Repo

      import Ecto
      import Ecto.Query
      import MseauthTest.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Mseauth.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Mseauth.Repo, {:shared, self()})
    end

    :ok
  end
end
