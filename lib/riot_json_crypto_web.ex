defmodule RiotJsonCryptoWeb do
  @moduledoc """
  The entrypoint for defining the HTTP interface.

  This can be used in your application as:

      use RiotJsonCryptoWeb, :controller

  The definitions below are executed for every router or controller, so keep
  them short and focused on imports, uses, and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:json]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: RiotJsonCryptoWeb.Endpoint,
        router: RiotJsonCryptoWeb.Router
    end
  end

  @doc """
  Dispatch to the requested router or controller definition.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
