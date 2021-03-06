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

    Mseauth.Session.AccessTokenWorker.expire(access_token)

    params = %{access_token: access_token}
    conn = send_json_req(:post, "/validate", params)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"identifier" => _} = Jason.decode!(conn.resp_body)

    params = %{refresh_token: refresh_token}
    conn = send_json_req(:put, "/refresh", params)

    assert conn.state == :sent
    assert conn.status == 201
    assert %{"access_token" => %{"value" => new_access_token}} = Jason.decode!(conn.resp_body)

    # Test new access_token is valid.
    params = %{access_token: new_access_token}
    conn = send_json_req(:post, "/validate", params)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"identifier" => _} = Jason.decode!(conn.resp_body)

    # Test old access_token is invalid.
    params = %{access_token: access_token}
    conn = send_json_req(:post, "/validate", params)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"status" => "failed"} = Jason.decode!(conn.resp_body)

    # Test not existing access_token is invalid.
    # TODO: fix this case.
    # params = %{access_token: "not existing access token"}
    # conn = send_json_req(:post, "/validate", params)
    #
    # assert conn.state == :sent
    # assert conn.status == 200
    # assert %{"status" => "failed"} = Jason.decode!(conn.resp_body)

    params = %{refresh_token: refresh_token}
    conn = send_json_req(:put, "/expire", params)

    assert conn.state == :sent
    assert conn.status == 200
    assert %{"status" => "succeeded"} = Jason.decode!(conn.resp_body)
  end

  defp send_json_req(method, path, params) do
    conn(method, path, params)
    |> put_req_header("content-type", "application/json")
    |> Server.call(@opts)
  end
end
