defmodule RiotApi.Payload do
  def map_depth_one(payload, transform) when is_map(payload) do
    Map.new(payload, fn {key, value} ->
      {key, transform.(value)}
    end)
  end

  def map_depth_one(payload, transform) when is_list(payload) do
    Enum.map(payload, transform)
  end

  def map_depth_one(payload, _transform) do
    payload
  end
end
