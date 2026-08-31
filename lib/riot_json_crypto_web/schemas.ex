defmodule RiotJsonCryptoWeb.Schemas do
  defmodule JsonValue do
    @behaviour OpenApiSpex.Schema

    @impl OpenApiSpex.Schema
    def schema do
      %OpenApiSpex.Schema{
        title: "JsonValue",
        description: "Any valid JSON value"
      }
    end
  end

  defmodule SignatureResponse do
    @behaviour OpenApiSpex.Schema

    @impl OpenApiSpex.Schema
    def schema do
      %OpenApiSpex.Schema{
        title: "SignatureResponse",
        type: :object,
        properties: %{
          signature: %OpenApiSpex.Schema{type: :string}
        },
        required: [:signature]
      }
    end
  end

  defmodule VerificationRequest do
    @behaviour OpenApiSpex.Schema

    @impl OpenApiSpex.Schema
    def schema do
      %OpenApiSpex.Schema{
        title: "VerificationRequest",
        type: :object,
        properties: %{
          data: JsonValue,
          signature: %OpenApiSpex.Schema{type: :string}
        },
        required: [:data, :signature]
      }
    end
  end
end
