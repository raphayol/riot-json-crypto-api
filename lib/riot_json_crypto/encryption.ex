defmodule RiotJsonCrypto.Encryption do
  alias RiotJsonCrypto.Payload

  def encrypt(payload, cipher) do
    Payload.map_depth_one(payload, fn value ->
      cipher.encrypt(value)
    end)
  end

  def decrypt(payload, cipher) do
    Payload.map_depth_one(payload, fn value ->
      cipher.decrypt(value)
    end)
  end
end
