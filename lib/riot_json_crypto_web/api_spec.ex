defmodule RiotJsonCryptoWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths}
  alias RiotJsonCryptoWeb.Router

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "Riot JSON Crypto API",
        version: "0.1.0"
      },
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
