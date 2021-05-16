defmodule Mix.Tasks.EndToEndTest do
  @moduledoc "Send actual HTTP requests in order to test the application"
  @shortdoc "Do End-to-end test to the local cluster."

  use Mix.Task

  require Logger

  @url "http://localhost:8080"
  @headers [{"Content-Type", "application/json"}]

  @impl Mix.Task
  def run(_args) do
    Logger.info("Start E2E test.")

    {:ok, _} = HTTPoison.start()

    1..10
    |> Enum.map(fn _ -> Task.async(&scenario1/0) end)
    |> Enum.each(&Task.await(&1, 30 * 1000))

    Logger.info("Complete E2E test.")
  end

  def scenario1 do
    sleep_randomly()

    {auth_id, password} = res = register()
    Logger.info("[#{inspect(self())}] Registered: #{inspect(res)}")

    sleep_randomly()

    {identifier, access_token, refresh_token} = res = authenticate(auth_id, password)
    Logger.info("[#{inspect(self())}] Authenticated: #{inspect(res)}")

    for _ <- 1..10 do
      sleep_randomly()

      tmp = validate(access_token)
      Logger.info("[#{inspect(self())}] Validated: #{tmp == identifier}, #{inspect(tmp)}")
    end

    access_token = refresh(refresh_token)
    Logger.info("[#{inspect(self())}] Refreshed: #{inspect(access_token)}")

    for _ <- 1..10 do
      sleep_randomly()

      tmp = validate(access_token)
      Logger.info("[#{inspect(self())}] Validated: #{tmp == identifier}, #{inspect(tmp)}")
    end
  end

  def register() do
    {auth_id, password} = gen_random_user()

    params =
      Jason.encode!(%{
        identifier: auth_id,
        password: password
      })

    resp = HTTPoison.post!("#{@url}/register", params, @headers)
    201 = resp.status_code
    %{"status" => "succeeded"} = Jason.decode!(resp.body)

    {auth_id, password}
  end

  def authenticate(identifier, password) do
    params = Jason.encode!(%{identifier: identifier, password: password})

    resp = HTTPoison.post!("#{@url}/authenticate", params, @headers)

    200 = resp.status_code

    %{
      "status" => "succeeded",
      "identifier" => identifier,
      "access_token" => %{"value" => access_token, "expired_at" => _},
      "refresh_token" => %{"value" => refresh_token, "expired_at" => _}
    } = Jason.decode!(resp.body)

    {identifier, access_token, refresh_token}
  end

  def validate(access_token) do
    params = Jason.encode!(%{access_token: access_token})

    resp = HTTPoison.post!("#{@url}/validate", params, @headers)

    200 = resp.status_code

    %{
      "status" => "succeeded",
      "identifier" => identifier
    } = Jason.decode!(resp.body)

    identifier
  end

  def refresh(refresh_token) do
    params = Jason.encode!(%{refresh_token: refresh_token})

    resp = HTTPoison.put!("#{@url}/refresh", params, @headers)

    201 = resp.status_code

    %{
      "status" => "succeeded",
      "access_token" => %{"value" => access_token, "expired_at" => _}
    } = Jason.decode!(resp.body)

    access_token
  end

  def sleep_randomly do
    (:rand.uniform_real() * 1000)
    |> ceil()
    |> Process.sleep()
  end

  def gen_random_user() do
    {gen_random_string(), gen_random_string()}
  end

  defp gen_random_string() do
    symbols = '0123456789abcdef'
    symbol_count = Enum.count(symbols)

    for _ <- 1..10, into: "" do
      <<Enum.at(symbols, :crypto.rand_uniform(0, symbol_count))>>
    end
  end
end
