defmodule RiotApiWeb.SignatureControllerTest do
  use RiotApiWeb.ConnCase, async: false

  defmodule SignerProbe do
    @behaviour RiotApi.Signer

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
    if context[:use_default_signer] do
      :ok
    else
      previous_signer = Application.fetch_env(:riot_api, :signer)

      Application.put_env(:riot_api, :signer, SignerProbe)

      on_exit(fn -> restore_env(:signer, previous_signer) end)

      :ok
    end
  end

  test "POST /sign uses the configured signer and secret", %{conn: conn} do
    conn = post_json(conn, ~p"/sign", %{"message" => "Hello"})

    assert json_response(conn, 200) == %{
             "signature" => ~s(signed:test-signing-secret:{"message":"Hello"})
           }
  end

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

  @tag use_default_signer: true
  test "POST /sign uses HMAC as the default signer", %{conn: conn} do
    conn = post_json(conn, ~p"/sign", %{"message" => "Hello"})

    assert json_response(conn, 200) == %{
             "signature" => "61579bfd6c15af8b7c1e2e79e0ca6b31431add01ed6fd3319b0d3f221bd7739a"
           }
  end

  test "POST /verify returns 204 for a valid signature", %{conn: conn} do
    payload = %{
      "data" => %{"message" => "Hello"},
      "signature" => ~s(signed:test-signing-secret:{"message":"Hello"})
    }

    conn = post_json(conn, ~p"/verify", payload)

    assert response(conn, 204) == ""
  end

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

  defp post_json(conn, path, payload) do
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("content-type", "application/json")
    |> post(path, Jason.encode!(payload))
  end

  defp restore_env(key, {:ok, value}) do
    Application.put_env(:riot_api, key, value)
  end

  defp restore_env(key, :error) do
    Application.delete_env(:riot_api, key)
  end
end
