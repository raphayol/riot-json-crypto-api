defmodule RiotJsonCryptoWeb.Router do
  use RiotJsonCryptoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: RiotJsonCryptoWeb.ApiSpec
  end

  scope "/", RiotJsonCryptoWeb do
    pipe_through :api
    post "/encrypt", EncryptionController, :encrypt
    post "/decrypt", EncryptionController, :decrypt
    post "/sign", SignatureController, :sign
    post "/verify", SignatureController, :verify
  end

  scope "/" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/" do
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
  end
end
