defmodule RiotJsonCryptoWeb.OpenAPITest do
  use RiotJsonCryptoWeb.ConnCase, async: true

  test "GET /openapi describes the four required operations", %{conn: conn} do
    spec =
      conn
      |> get(~p"/openapi")
      |> json_response(200)

    assert Map.keys(spec["paths"]) |> Enum.sort() ==
             Enum.sort(["/decrypt", "/encrypt", "/sign", "/verify"])

    for path <- Map.keys(spec["paths"]) do
      assert %{"post" => _operation} = spec["paths"][path]
    end
  end

  test "GET /docs serves Swagger UI", %{conn: conn} do
    conn = get(conn, ~p"/docs")

    assert html_response(conn, 200) =~ "Swagger UI"
  end
end
