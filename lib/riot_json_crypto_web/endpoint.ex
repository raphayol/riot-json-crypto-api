defmodule RiotJsonCryptoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :riot_json_crypto

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Phoenix.json_library(),
    nest_all_json: true

  plug RiotJsonCryptoWeb.Router
end
