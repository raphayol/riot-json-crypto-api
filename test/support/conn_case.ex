defmodule RiotJsonCryptoWeb.ConnCase do
  @moduledoc """
  Test case for requests sent through the Phoenix endpoint.

  It provides a fresh connection and imports the helpers used by HTTP boundary
  tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint RiotJsonCryptoWeb.Endpoint

      use RiotJsonCryptoWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import RiotJsonCryptoWeb.ConnCase
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
