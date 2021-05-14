defmodule Mseauth.Server do
  use Plug.Router

  use Plug.ErrorHandler

  alias Mseauth.Authenticator

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/register" do
    with %{
           "identifier" => identifier,
           "password" => password
         } <- conn.body_params do
      :ok = Authenticator.register(identifier, password)
      send_resp(conn, 200, "")
    else
      _ ->
        send_resp(conn, 400, "error")
    end
  end

  post "/validate" do
    with %{
           "identifier" => identifier,
           "password" => password
         } <- conn.body_params do
      {:ok, {identifier, access_token, refresh_token}} =
        Authenticator.validate(identifier, password)

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(
        200,
        Jason.encode!(%{
          identifier: identifier,
          access_token: access_token,
          refresh_token: refresh_token
        })
      )
    else
      _ ->
        send_resp(conn, 400, "error")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
