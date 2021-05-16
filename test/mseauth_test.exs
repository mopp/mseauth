defmodule MseauthTest do
  use ExUnit.Case
  use MseauthTest.RepoCase
  use Plug.Test

  alias Mseauth.Repo
  alias Mseauth.Repo.User
  alias Mseauth.Server

  @opts Server.init([])

  test "normal case" do
    params = %{identifier: "mopp", password: "yomogi"}
    conn = send_json_req(:post, "/register", params)

    assert :sent == conn.state
    assert 201 == conn.status
    assert %{"status" => "succeeded"} == Jason.decode!(conn.resp_body)

    assert [%User{auth_id: "mopp"}] = Repo.all(User)

    params = %{identifier: "mopp", password: "yomogi"}
    conn = send_json_req(:post, "/authenticate", params)

    assert :sent == conn.state
    assert 200 == conn.status

    assert %{
             "identifier" => _,
             "access_token" => access_token,
             "refresh_token" => _refresh_token
           } = Jason.decode!(conn.resp_body)

    params = %{access_token: access_token}
    conn = send_json_req(:post, "/validate", params)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"identifier" => _} = Jason.decode!(conn.resp_body)
  end

  defp send_json_req(method, path, params) do
    conn(method, path, params)
    |> put_req_header("content-type", "application/json")
    |> Server.call(@opts)
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
