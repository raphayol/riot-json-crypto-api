defmodule RiotApiWeb.SignatureController do
  use RiotApiWeb, :controller

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
    Application.fetch_env!(:riot_api, :signer)
  end

  defp signing_secret do
    Application.fetch_env!(:riot_api, :signing_secret)
  end
end
