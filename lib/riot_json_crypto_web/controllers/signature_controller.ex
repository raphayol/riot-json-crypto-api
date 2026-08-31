defmodule RiotJsonCryptoWeb.SignatureController do
  use RiotJsonCryptoWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias RiotJsonCryptoWeb.Schemas.{JsonValue, SignatureResponse, VerificationRequest}

  tags ["signature"]

  operation :sign,
    summary: "Sign a JSON payload",
    request_body: {"JSON payload", "application/json", JsonValue, required: true},
    responses: [ok: {"Payload signature", "application/json", SignatureResponse}]

  operation :verify,
    summary: "Verify a JSON payload signature",
    request_body:
      {"Payload and signature", "application/json", VerificationRequest, required: true},
    responses: [
      no_content: "Signature is valid",
      bad_request: "Signature or request is invalid"
    ]

  def sign(conn, %{"_json" => payload}) do
    signature = signer().sign(payload, signing_secret())

    json(conn, %{signature: signature})
  end

  def verify(conn, %{"_json" => %{"data" => data, "signature" => signature}})
      when is_binary(signature) do
    if signer().valid?(data, signature, signing_secret()) do
      send_resp(conn, :no_content, "")
    else
      send_resp(conn, :bad_request, "")
    end
  end

  def verify(conn, _params) do
    send_resp(conn, :bad_request, "")
  end

  defp signer do
    Application.fetch_env!(:riot_json_crypto, :signer)
  end

  defp signing_secret do
    Application.fetch_env!(:riot_json_crypto, :signing_secret)
  end
end
