defmodule RiotJsonCryptoWeb.Router do
  use RiotJsonCryptoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RiotJsonCryptoWeb do
    pipe_through :api
    post "/encrypt", EncryptionController, :encrypt
    post "/decrypt", EncryptionController, :decrypt
    post "/sign", SignatureController, :sign
    post "/verify", SignatureController, :verify
  end
end
