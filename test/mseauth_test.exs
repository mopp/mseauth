defmodule MseauthTest do
  use ExUnit.Case, async: true
  use Plug.Test
  use MseauthTest.RepoCase

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

    conn =
      conn(:post, "/validate", %{identifier: "mopp", password: "yomogi"})
      |> put_req_header("content-type", "application/json")
      |> Server.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    assert %{
             "identifier" => "mopp",
             "access_token" => _,
             "refresh_token" => _
           } = Jason.decode!(conn.resp_body)
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
