defmodule RiotApi.Cipher do
  @moduledoc """
  Contract implemented by reversible transformation algorithms.
  """

  @callback encrypt(value :: term()) :: String.t()
  @callback decrypt(value :: term()) :: term()
end
