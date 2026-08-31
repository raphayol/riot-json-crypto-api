defmodule RiotJsonCrypto.Signer.HMAC do
  @behaviour RiotJsonCrypto.Signer

  alias RiotJsonCrypto.CanonicalJSON

  @impl true
  def sign(value, secret) when is_binary(secret) do
    :crypto.mac(:hmac, :sha256, secret, CanonicalJSON.encode(value))
    |> Base.encode16(case: :lower)
  end

  @impl true
  def valid?(value, signature, secret)
      when is_binary(signature) and is_binary(secret) do
    expected_signature = sign(value, secret)

    Plug.Crypto.secure_compare(expected_signature, signature)
  end

  def valid?(_value, _signature, _secret) do
    false
  end
end
