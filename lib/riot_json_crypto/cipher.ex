defmodule RiotJsonCrypto.Cipher do
  @moduledoc """
  Contract implemented by reversible transformation algorithms.
  """

  @type json_value ::
          nil
          | boolean()
          | number()
          | String.t()
          | [json_value()]
          | %{optional(String.t()) => json_value()}

  @doc """
  Encrypts a decoded JSON value into a ciphertext string.
  """
  @callback encrypt(value :: json_value()) :: String.t()

  @doc """
  Decrypts recognized ciphertext and returns unrecognized JSON values unchanged.
  """
  @callback decrypt(value :: json_value()) :: json_value()
end
