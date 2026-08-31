defmodule RiotJsonCryptoWeb.EncryptionControllerTest do
  use RiotJsonCryptoWeb.ConnCase, async: false

  defmodule CipherProbe do
    @behaviour RiotJsonCrypto.Cipher

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
    case context[:cipher] do
      nil ->
        :ok

      cipher ->
        previous_cipher = Application.fetch_env(:riot_json_crypto, :cipher)

        Application.put_env(:riot_json_crypto, :cipher, cipher)

        on_exit(fn ->
          case previous_cipher do
            {:ok, previous_cipher} ->
              Application.put_env(:riot_json_crypto, :cipher, previous_cipher)

            :error ->
              Application.delete_env(:riot_json_crypto, :cipher)
          end
        end)

        :ok
    end
  end

  @tag cipher: CipherProbe
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

  @tag cipher: CipherProbe
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

  test "POST /encrypt output round-trips through POST /decrypt for every JSON shape" do
    payloads = [
      %{
        "name" => "John",
        "age" => 30,
        "contact" => %{"email" => "john@example.com"},
        "roles" => ["admin", nil, true]
      },
      ["John", 30, %{"active" => true}],
      "hello",
      42,
      true,
      nil
    ]

    for payload <- payloads do
      encrypted_payload =
        build_conn()
        |> post_json(~p"/encrypt", payload)
        |> json_response(200)

      conn = post_json(build_conn(), ~p"/decrypt", encrypted_payload)

      assert json_response(conn, 200) == payload
    end
  end

  test "POST /decrypt preserves unencrypted depth-one values" do
    payload = %{
      "plain_text" => "1998-11-19",
      "base64_looking" => "MzA=",
      "number" => 30,
      "nested" => %{"active" => true}
    }

    conn = post_json(build_conn(), ~p"/decrypt", payload)

    assert json_response(conn, 200) == payload
  end

  defp post_json(conn, path, payload) do
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("content-type", "application/json")
    |> post(path, Jason.encode!(payload))
  end
end
