defmodule RiotJsonCrypto.Signer do
  @moduledoc """
  Contract implemented by JSON signature algorithms.
  """

  @type json_value :: RiotJsonCrypto.Cipher.json_value()

  @doc """
  Produces a signature for a decoded JSON value using the supplied secret.
  """
  @callback sign(value :: json_value(), secret :: binary()) :: String.t()

  @doc """
  Checks whether a signature belongs to a decoded JSON value.
  """
  @callback valid?(value :: json_value(), signature :: String.t(), secret :: binary()) ::
              boolean()
end
