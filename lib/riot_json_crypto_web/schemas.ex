defmodule RiotJsonCryptoWeb.Schemas do
  defmodule JsonValue do
    @behaviour OpenApiSpex.Schema

    @impl OpenApiSpex.Schema
    def schema do
      %OpenApiSpex.Schema{
        title: "JsonValue",
        description: "Any valid JSON value",
        example: %{
          "name" => "John",
          "age" => 30
        }
      }
    end
  end

  defmodule EncryptedJsonValue do
    @behaviour OpenApiSpex.Schema

    @impl OpenApiSpex.Schema
    def schema do
      %OpenApiSpex.Schema{
        title: "EncryptedJsonValue",
        description: "JSON values transformed by the default Base64 cipher",
        example: %{
          "name" => "cmlvdDpiYXNlNjQ6djE6IkpvaG4i",
          "age" => "cmlvdDpiYXNlNjQ6djE6MzA="
        }
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
        required: [:signature],
        example: %{
          "signature" => "signature-returned-for-the-request-payload"
        }
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
        required: [:data, :signature],
        example: %{
          "data" => %{
            "name" => "John",
            "age" => 30
          },
          "signature" => "paste-signature-returned-by-sign"
        }
      }
    end
  end
end
