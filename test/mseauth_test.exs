defmodule MseauthTest do
  import Ecto.Query

  use ExUnit.Case
  use MseauthTest.RepoCase
  use Plug.Test

  alias Mseauth.Repo
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken
  alias Mseauth.Repo.Session
  alias Mseauth.Repo.User
  alias Mseauth.Server

  @opts Server.init([])

  test "normal case" do
    conn =
      conn(:post, "/register", %{identifier: "mopp", password: "yomogi"})
      |> put_req_header("content-type", "application/json")
      |> Server.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == ""

    assert [%User{auth_id: "mopp"}] = Repo.all(User)

    conn =
      conn(:post, "/authenticate", %{identifier: "mopp", password: "yomogi"})
      |> put_req_header("content-type", "application/json")
      |> Server.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert %{
             "identifier" => _,
             "access_token" => access_token,
             "refresh_token" => access_token
           } = Jason.decode!(conn.resp_body)

    # TODO: assert more.
    assert 1 =
             Session
             |> preload([:access_token, :refresh_token])
             |> Repo.all()
             |> length

    conn =
      conn(:post, "/validate", %{access_token: access_token})
      |> put_req_header("content-type", "application/json")
      |> Server.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"identifier" => _identifier} == Jason.decode!(conn.resp_body)
  end

  # test "whole use case" do
  #   :ok = Mseauth.register(identifier, password)
  #   {identifier, access_token, refresh_token} = Mseauth.authenticate(identifier, password)
  #
  #   :ok = Mseauth.validate(access_token)
  #
  #   {access_token, refresh_token} = Mseauth.refresh(refresh_token)
  #
  #   :ok = Mseauth.expire(access_token)
  #
  #   :ok = Mseauth.change_password(identifier, current_password, new_password)
  #
  #   :ok = Mseauth.withdraw(identifier, password)
  # end
end
