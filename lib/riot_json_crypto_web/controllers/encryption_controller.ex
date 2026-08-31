defmodule RiotJsonCryptoWeb.EncryptionController do
  use RiotJsonCryptoWeb, :controller

  alias RiotJsonCrypto.Encryption

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
