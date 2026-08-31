defmodule RiotJsonCrypto.EncryptionTest do
  use ExUnit.Case, async: true

  alias RiotJsonCrypto.Encryption

  defmodule CipherProbe do
    @behaviour RiotJsonCrypto.Cipher

    @impl true
    def encrypt(value) do
      "encrypted:" <> Jason.encode!(value)
    end

    @impl true
    def decrypt(value) do
      "decrypted:" <> Jason.encode!(value)
    end
  end

  test "encrypts each depth-one value with the selected cipher" do
    payload = %{
      "name" => "John",
      "contact" => %{"email" => "john@example.com"}
    }

    assert Encryption.encrypt(payload, CipherProbe) == %{
             "name" => ~s(encrypted:"John"),
             "contact" => ~s(encrypted:{"email":"john@example.com"})
           }
  end

  test "decrypts each depth-one value with the selected cipher" do
    payload = %{
      "name" => "ciphertext-name",
      "contact" => "ciphertext-contact"
    }

    assert Encryption.decrypt(payload, CipherProbe) == %{
             "name" => ~s(decrypted:"ciphertext-name"),
             "contact" => ~s(decrypted:"ciphertext-contact")
           }
  end
end
