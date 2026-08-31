defmodule RiotJsonCrypto.Cipher.Base64 do
  @behaviour RiotJsonCrypto.Cipher
  @marker "riot:base64:v1:"

  @impl true
  def encrypt(value) do
    json = Jason.encode!(value)
    Base.encode64(@marker <> json)
  end

  @impl true
  def decrypt(ciphertext) when is_binary(ciphertext) do
    with {:ok, decoded} <- Base.decode64(ciphertext),
         true <- Base.encode64(decoded) == ciphertext,
         ["", json] <- String.split(decoded, @marker, parts: 2),
         {:ok, value} <- Jason.decode(json) do
      value
    else
      _ -> ciphertext
    end
  end

  def decrypt(value) do
    value
  end
end
