defmodule RiotApiWeb.EncryptionController do
  use RiotApiWeb, :controller

  alias RiotApi.Encryption

  def encrypt(conn, %{"_json" => payload}) do
    cipher = Application.fetch_env!(:riot_api, :cipher)
    encrypted_payload = Encryption.encrypt(payload, cipher)

    json(conn, encrypted_payload)
  end

  def decrypt(conn, %{"_json" => payload}) do
    cipher = Application.fetch_env!(:riot_api, :cipher)
    decrypted_payload = Encryption.decrypt(payload, cipher)

    json(conn, decrypted_payload)
  end
end
