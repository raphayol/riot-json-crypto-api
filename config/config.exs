# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

import Config

# Configure the endpoint
config :riot_json_crypto, RiotJsonCryptoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: RiotJsonCryptoWeb.ErrorJSON],
    layout: false
  ]

# Configure the default reversible transformation
config :riot_json_crypto, :cipher, RiotJsonCrypto.Cipher.Base64

# Configure the default signature algorithm
config :riot_json_crypto, :signer, RiotJsonCrypto.Signer.HMAC

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
