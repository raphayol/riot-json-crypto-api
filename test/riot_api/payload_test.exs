defmodule RiotApi.PayloadTest do
  use ExUnit.Case, async: true

  alias RiotApi.Payload

  test "transforms each immediate value of an object" do
    payload = %{
      "name" => "John",
      "contact" => %{"email" => "john@example.com"}
    }

    transform = fn value -> {:transformed, value} end

    assert Payload.map_depth_one(payload, transform) == %{
             "name" => {:transformed, "John"},
             "contact" => {:transformed, %{"email" => "john@example.com"}}
           }
  end

  test "transforms each element of a top-level array" do
    payload = [
      "John",
      30,
      %{"email" => "john@example.com"}
    ]

    transform = fn value -> {:transformed, value} end

    assert Payload.map_depth_one(payload, transform) == [
             {:transformed, "John"},
             {:transformed, 30},
             {:transformed, %{"email" => "john@example.com"}}
           ]
  end

  test "returns a top-level primitive unchanged" do
    transform = fn value -> {:transformed, value} end

    for payload <- [42, 3.14, "hello", true, false, nil] do
      assert Payload.map_depth_one(payload, transform) == payload
    end
  end

  test "returns empty containers without calling the transformation" do
    transform = fn _value ->
      flunk("the transformation should not be called")
    end

    assert Payload.map_depth_one(%{}, transform) == %{}
    assert Payload.map_depth_one([], transform) == []
  end
end
