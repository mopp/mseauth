defmodule MseauthTest do
  use ExUnit.Case
  use MseauthTest.RepoCase
  use Plug.Test

  alias Mseauth.Repo
  alias Mseauth.Repo.User
  alias Mseauth.Repo.AccessToken
  alias Mseauth.Repo.RefreshToken
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
             "identifier" => identifier,
             "access_token" => %{"value" => access_token, "expired_at" => _},
             "refresh_token" => %{"value" => refresh_token, "expired_at" => _}
           } = Jason.decode!(conn.resp_body)

    assert [%AccessToken{id: ^access_token, user_id: ^identifier}] = Repo.all(AccessToken)
    assert [%RefreshToken{id: ^refresh_token, user_id: ^identifier}] = Repo.all(RefreshToken)

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
