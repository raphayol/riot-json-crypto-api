defmodule RiotJsonCryptoWeb.EncryptionController do
  use RiotJsonCryptoWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias RiotJsonCrypto.Encryption
  alias RiotJsonCryptoWeb.Schemas.JsonValue

  tags ["encryption"]

  operation :encrypt,
    summary: "Encrypt a JSON payload",
    request_body: {"JSON payload", "application/json", JsonValue, required: true},
    responses: [ok: {"Encrypted JSON payload", "application/json", JsonValue}]

  operation :decrypt,
    summary: "Decrypt a JSON payload",
    request_body: {"Encrypted JSON payload", "application/json", JsonValue, required: true},
    responses: [ok: {"Decrypted JSON payload", "application/json", JsonValue}]

  def encrypt(conn, %{"_json" => payload}) do
    cipher = Application.fetch_env!(:riot_json_crypto, :cipher)
    encrypted_payload = Encryption.encrypt(payload, cipher)

    json(conn, encrypted_payload)
  end

  def decrypt(conn, %{"_json" => payload}) do
    cipher = Application.fetch_env!(:riot_json_crypto, :cipher)
    decrypted_payload = Encryption.decrypt(payload, cipher)

    json(conn, decrypted_payload)
  end
end
