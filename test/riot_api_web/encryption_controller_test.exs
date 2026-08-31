defmodule RiotApiWeb.EncryptionControllerTest do
  use RiotApiWeb.ConnCase, async: false

  defmodule CipherProbe do
    @behaviour RiotApi.Cipher

    @impl true
    def encrypt(value) do
      "encrypted:" <> Jason.encode!(value)
    end

    @impl true
    def decrypt(value) do
      "decrypted:" <> Jason.encode!(value)
    end
  end

  setup context do
    if context[:use_default_cipher] do
      :ok
    else
      previous_cipher = Application.fetch_env(:riot_api, :cipher)

      Application.put_env(:riot_api, :cipher, CipherProbe)

      on_exit(fn ->
        case previous_cipher do
          {:ok, cipher} ->
            Application.put_env(:riot_api, :cipher, cipher)

          :error ->
            Application.delete_env(:riot_api, :cipher)
        end
      end)

      :ok
    end
  end

  test "POST /encrypt uses the configured cipher", %{conn: conn} do
    payload = %{"value" => "John"}

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(~p"/encrypt", Jason.encode!(payload))

    assert json_response(conn, 200) == %{
             "value" => ~s(encrypted:"John")
           }
  end

  @tag use_default_cipher: true
  test "POST /encrypt uses Base64 as the default cipher", %{conn: conn} do
    payload = %{"age" => 30}

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(~p"/encrypt", Jason.encode!(payload))

    assert json_response(conn, 200) == %{
             "age" => "cmlvdDpiYXNlNjQ6djE6MzA="
           }
  end

  test "POST /decrypt uses the configured cipher", %{conn: conn} do
    payload = %{"value" => "ciphertext"}

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(~p"/decrypt", Jason.encode!(payload))

    assert json_response(conn, 200) == %{
             "value" => ~s(decrypted:"ciphertext")
           }
  end
end
