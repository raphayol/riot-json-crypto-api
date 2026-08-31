defmodule RiotApi.CanonicalJSONTest do
  use ExUnit.Case, async: true

  alias RiotApi.CanonicalJSON

  test "sorts object keys lexicographically" do
    value = %{"z" => 2, "a" => 1}

    assert CanonicalJSON.encode(value) == ~s({"a":1,"z":2})
  end

  test "sorts nested objects and preserves array order" do
    value = %{
      "z" => [%{"b" => 2, "a" => 1}, "second"],
      "a" => true
    }

    assert CanonicalJSON.encode(value) ==
             ~s({"a":true,"z":[{"a":1,"b":2},"second"]})
  end

  test "encodes primitive values as JSON" do
    fixtures = [
      {30, "30"},
      {3.5, "3.5"},
      {"hello", ~s("hello")},
      {true, "true"},
      {false, "false"},
      {nil, "null"}
    ]

    for {value, expected} <- fixtures do
      assert CanonicalJSON.encode(value) == expected
    end
  end
end
