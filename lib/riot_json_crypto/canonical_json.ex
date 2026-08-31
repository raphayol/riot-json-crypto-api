defmodule RiotJsonCrypto.CanonicalJSON do
  @moduledoc """
  Encodes decoded JSON values into a deterministic JSON representation.
  """

  @spec encode(RiotJsonCrypto.Cipher.json_value()) :: String.t()
  def encode(value) do
    value
    |> encode_to_iodata()
    |> IO.iodata_to_binary()
  end

  defp encode_to_iodata(value) when is_map(value) do
    entries =
      value
      |> Enum.sort_by(fn {key, _value} -> key end)
      |> Enum.map(fn {key, nested_value} ->
        [Jason.encode!(key), ?:, encode_to_iodata(nested_value)]
      end)

    [?{, Enum.intersperse(entries, ?,), ?}]
  end

  defp encode_to_iodata(value) when is_list(value) do
    values = Enum.map(value, &encode_to_iodata/1)

    [?[, Enum.intersperse(values, ?,), ?]]
  end

  defp encode_to_iodata(value) do
    Jason.encode!(value)
  end
end
