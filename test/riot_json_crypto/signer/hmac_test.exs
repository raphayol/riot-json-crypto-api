defmodule RiotJsonCrypto.Signer.HMACTest do
  use ExUnit.Case, async: true

  alias RiotJsonCrypto.Signer.HMAC

  @secret "test-secret"

  test "produces the expected lowercase HMAC-SHA256 signature" do
    payload = %{
      "message" => "Hello World",
      "timestamp" => 1_616_161_616
    }

    assert HMAC.sign(payload, @secret) ==
             "dc8aa128f1bfd555488d955ca1cf5d8621852d66da2f1d3c0b9e2c85728d4675"
  end

  test "ignores object property order" do
    first = Jason.decode!(~s({"message":"Hello World","timestamp":1616161616}))
    second = Jason.decode!(~s({"timestamp":1616161616,"message":"Hello World"}))

    assert HMAC.sign(first, @secret) == HMAC.sign(second, @secret)
  end

  test "preserves array order when signing" do
    refute HMAC.sign([1, 2], @secret) == HMAC.sign([2, 1], @secret)
  end

  test "validates matching signatures and rejects modified input" do
    payload = %{"message" => "Hello World"}
    signature = HMAC.sign(payload, @secret)

    assert HMAC.valid?(payload, signature, @secret)
    refute HMAC.valid?(%{"message" => "Goodbye World"}, signature, @secret)
    refute HMAC.valid?(payload, "invalid", @secret)
    refute HMAC.valid?(payload, nil, @secret)
  end
end
