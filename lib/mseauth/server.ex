defmodule Mseauth.Server do
  use Plug.Router
  use Plug.ErrorHandler

  require Logger

  alias Mseauth.Authentication
  alias Mseauth.Session

  plug Plug.Logger, log: :debug
  plug :match

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :dispatch

  post "/register" do
    {status, params} =
      with %{
             "identifier" => identifier,
             "password" => password
           } <- conn.body_params,
           :ok <- Authentication.register(identifier, password) do
        {201, %{status: :succeeded}}
      else
        {:error, _reason} ->
          {200, %{status: :failed, reason: "something wrong"}}

        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  put "/change_password" do
    {status, params} =
      with %{
             "identifier" => identifier,
             "old_password" => old_password,
             "new_password" => new_password
           } <- conn.body_params,
           :ok <- Authentication.change_password(identifier, old_password, new_password) do
        {200, %{status: :succeeded}}
      else
        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  # TODO: Use proper HTTP method.
  post "/authenticate" do
    {status, params} =
      with %{"identifier" => identifier, "password" => password} <- conn.body_params,
           {:ok, user} <- Authentication.authenticate(identifier, password),
           {:ok, {access_token, refresh_token}} <- Session.start(user) do
        {200,
         %{
           status: :succeeded,
           identifier: user.id,
           access_token: %{value: access_token.id, expired_at: access_token.expired_at},
           refresh_token: %{value: refresh_token.id, expired_at: refresh_token.expired_at}
         }}
      else
        {:error, :authentication_failed} ->
          {401, %{status: :failed, reason: "Authentication failed."}}

        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  post "/validate" do
    {status, params} =
      with %{"access_token" => access_token} <- conn.body_params,
           {:ok, identifier} <- Session.validate(access_token) do
        {200,
         %{
           status: :succeeded,
           identifier: identifier
         }}
      else
        {:error, :expired} ->
          {200, %{status: :failed, reason: "The given access token was already expired."}}

        _ ->
          {400, %{status: :error}}
      end

    send_json_resp(conn, status, params)
  end

  put "/refresh" do
    {status, params} =
      with %{"refresh_token" => refresh_token} <- conn.body_params,
           {:ok, access_token} <- Session.refresh(refresh_token) do
        {201,
         %{
           status: :succeeded,
           access_token: %{value: access_token.id, expired_at: access_token.expired_at}
         }}
      else
        {:error, :expired} ->
          {200, %{status: :failed, reason: "The given refresh token was already expired."}}

        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  put "/expire" do
    {status, params} =
      with %{"refresh_token" => refresh_token} <- conn.body_params,
           :ok <- Session.expire(refresh_token) do
        {200, %{status: :succeeded}}
      else
        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  delete "/withdraw" do
    {status, params} =
      with %{
             "identifier" => identifier,
             "password" => password
           } <- conn.body_params,
           :ok <- Authentication.withdraw(identifier, password) do
        {200, %{status: :succeeded}}
      else
        _ ->
          {400, %{status: :error, reason: "invalid request"}}
      end

    send_json_resp(conn, status, params)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack} = info) do
    Logger.error(inspect(info))
    send_resp(conn, conn.status, "Something went wrong")
  end

  defp send_json_resp(conn, status, params) when is_integer(status) and is_map(params) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(params))
  end
end
