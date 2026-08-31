defmodule RiotJsonCryptoWeb.SignatureControllerTest do
  use RiotJsonCryptoWeb.ConnCase, async: false

  defmodule SignerProbe do
    @behaviour RiotJsonCrypto.Signer

    @impl true
    def sign(value, secret) do
      "signed:" <> secret <> ":" <> Jason.encode!(value)
    end

    @impl true
    def valid?(value, signature, secret) when is_binary(signature) do
      signature == sign(value, secret)
    end

    def valid?(_value, _signature, _secret) do
      false
    end
  end

  setup context do
    case context[:signer] do
      nil ->
        :ok

      signer ->
        previous_signer = Application.fetch_env(:riot_json_crypto, :signer)

        Application.put_env(:riot_json_crypto, :signer, signer)

        on_exit(fn -> restore_env(:signer, previous_signer) end)

        :ok
    end
  end

  @tag signer: SignerProbe
  test "POST /sign uses the configured signer and secret", %{conn: conn} do
    conn = post_json(conn, ~p"/sign", %{"message" => "Hello"})

    assert json_response(conn, 200) == %{
             "signature" => ~s(signed:test-signing-secret:{"message":"Hello"})
           }
  end

  @tag signer: SignerProbe
  test "POST /sign accepts top-level arrays and primitives" do
    for {payload, encoded_payload} <- [
          {["Hello", 42], ~s(["Hello",42])},
          {42, "42"}
        ] do
      conn = post_json(build_conn(), ~p"/sign", payload)

      assert json_response(conn, 200) == %{
               "signature" => "signed:test-signing-secret:" <> encoded_payload
             }
    end
  end

  test "POST /sign uses HMAC as the default signer", %{conn: conn} do
    conn = post_json(conn, ~p"/sign", %{"message" => "Hello"})

    assert json_response(conn, 200) == %{
             "signature" => "61579bfd6c15af8b7c1e2e79e0ca6b31431add01ed6fd3319b0d3f221bd7739a"
           }
  end

  @tag signer: SignerProbe
  test "POST /verify returns 204 for a valid signature", %{conn: conn} do
    payload = %{
      "data" => %{"message" => "Hello"},
      "signature" => ~s(signed:test-signing-secret:{"message":"Hello"})
    }

    conn = post_json(conn, ~p"/verify", payload)

    assert response(conn, 204) == ""
  end

  @tag signer: SignerProbe
  test "POST /verify accepts arrays and primitives as data" do
    for data <- [["Hello", 42], 42] do
      payload = %{
        "data" => data,
        "signature" => "signed:test-signing-secret:" <> Jason.encode!(data)
      }

      conn = post_json(build_conn(), ~p"/verify", payload)

      assert response(conn, 204) == ""
    end
  end

  test "POST /verify returns 400 for an invalid signature", %{conn: conn} do
    payload = %{
      "data" => %{"message" => "Hello"},
      "signature" => "invalid"
    }

    conn = post_json(conn, ~p"/verify", payload)

    assert response(conn, 400) == ""
  end

  test "POST /verify returns 400 for a malformed request", %{conn: conn} do
    conn = post_json(conn, ~p"/verify", %{"data" => %{"message" => "Hello"}})

    assert response(conn, 400) == ""
  end

  test "POST /verify returns 400 for a non-object request", %{conn: conn} do
    conn = post_json(conn, ~p"/verify", ["not", "a", "request object"])

    assert response(conn, 400) == ""
  end

  test "POST /sign output verifies through POST /verify for every JSON shape" do
    values = [
      %{"message" => "Hello", "nested" => %{"active" => true}},
      ["Hello", 42, nil],
      "hello",
      42,
      true,
      nil
    ]

    for value <- values do
      %{"signature" => signature} =
        build_conn()
        |> post_json(~p"/sign", value)
        |> json_response(200)

      verification = %{"data" => value, "signature" => signature}
      conn = post_json(build_conn(), ~p"/verify", verification)

      assert response(conn, 204) == ""
    end
  end

  test "POST /sign and POST /verify ignore object property order" do
    first = ~s({"message":"Hello World","timestamp":1616161616})
    reordered = ~s({"timestamp":1616161616,"message":"Hello World"})

    %{"signature" => signature} =
      build_conn()
      |> post_raw_json(~p"/sign", first)
      |> json_response(200)

    %{"signature" => reordered_signature} =
      build_conn()
      |> post_raw_json(~p"/sign", reordered)
      |> json_response(200)

    assert reordered_signature == signature

    verification =
      ~s({"signature":"#{signature}","data":{"timestamp":1616161616,"message":"Hello World"}})

    conn = post_raw_json(build_conn(), ~p"/verify", verification)

    assert response(conn, 204) == ""
  end

  test "POST /verify rejects data or signature modified after POST /sign" do
    original = %{"message" => "Hello World", "timestamp" => 1_616_161_616}

    %{"signature" => signature} =
      build_conn()
      |> post_json(~p"/sign", original)
      |> json_response(200)

    modified_data = %{
      "message" => "Goodbye World",
      "timestamp" => 1_616_161_616
    }

    modified_signature = String.duplicate("0", 64)

    refute modified_signature == signature

    invalid_verifications = [
      %{"data" => modified_data, "signature" => signature},
      %{"data" => original, "signature" => modified_signature}
    ]

    for verification <- invalid_verifications do
      conn = post_json(build_conn(), ~p"/verify", verification)

      assert response(conn, 400) == ""
    end
  end

  defp post_json(conn, path, payload) do
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("content-type", "application/json")
    |> post(path, Jason.encode!(payload))
  end

  defp post_raw_json(conn, path, body) do
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("content-type", "application/json")
    |> post(path, body)
  end

  defp restore_env(key, {:ok, value}) do
    Application.put_env(:riot_json_crypto, key, value)
  end

  defp restore_env(key, :error) do
    Application.delete_env(:riot_json_crypto, key)
  end
end
