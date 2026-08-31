defmodule RiotJsonCrypto.Cipher.Base64Test do
  use ExUnit.Case, async: true

  alias RiotJsonCrypto.Cipher.Base64

  test "encrypts a JSON value using the versioned marker" do
    assert Base64.encrypt(30) == "cmlvdDpiYXNlNjQ6djE6MzA="
  end

  test "serializes strings as JSON before encoding" do
    encrypted_number = Base64.encrypt(30)
    encrypted_string = Base64.encrypt("30")

    refute encrypted_string == encrypted_number

    assert Base.decode64!(encrypted_string) ==
             ~s(riot:base64:v1:"30")
  end

  test "decrypts a value containing the expected marker" do
    ciphertext = "cmlvdDpiYXNlNjQ6djE6MzA="

    assert Base64.decrypt(ciphertext) == 30
  end

  test "returns malformed Base64 unchanged" do
    value = "not base64!"

    assert Base64.decrypt(value) == value
  end

  test "returns valid Base64 without the expected marker unchanged" do
    value = "MzA="

    assert Base64.decrypt(value) == value
  end

  test "returns marked Base64 containing invalid JSON unchanged" do
    value = Base.encode64("riot:base64:v1:not-json")

    assert Base64.decrypt(value) == value
  end

  test "returns Base64 decoding to non-UTF-8 bytes unchanged" do
    values = [
      Base.encode64(<<255>>),
      Base.encode64("riot:base64:v1:" <> <<255>>)
    ]

    for value <- values do
      assert Base64.decrypt(value) == value
    end
  end

  test "returns non-string JSON values unchanged" do
    values = [
      30,
      3.14,
      true,
      false,
      nil,
      [1, 2],
      %{"name" => "John"}
    ]

    for value <- values do
      assert Base64.decrypt(value) == value
    end
  end

  test "returns non-canonical Base64 unchanged" do
    canonical = "cmlvdDpiYXNlNjQ6djE6MzA="
    non_canonical = "cmlvdDpiYXNlNjQ6djE6MzB="

    assert Base.decode64!(non_canonical) ==
             Base.decode64!(canonical)

    assert Base64.decrypt(non_canonical) == non_canonical
  end

  test "round-trips every JSON value type" do
    values = [
      "John",
      30,
      3.14,
      true,
      false,
      nil,
      [1, "two", %{"nested" => true}],
      %{"name" => "John", "roles" => ["admin", "user"]}
    ]

    for value <- values do
      assert value
             |> Base64.encrypt()
             |> Base64.decrypt() == value
    end
  end

  test "decrypts exactly one encryption layer at a time" do
    original = %{"name" => "John"}

    encrypted_once = Base64.encrypt(original)
    encrypted_twice = Base64.encrypt(encrypted_once)

    assert Base64.decrypt(encrypted_twice) == encrypted_once

    assert encrypted_twice
           |> Base64.decrypt()
           |> Base64.decrypt() == original
  end
end
