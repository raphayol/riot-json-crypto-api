# Riot JSON Crypto API

An Elixir/Phoenix implementation of the
[Riot backend take-home exercise](https://github.com/tryriot/take-home). The
service accepts arbitrary JSON payloads and exposes operations for reversible
Base64 transformation and signature creation/verification.

The project is intentionally implemented as a small JSON-only API. It has no
database, HTML interface, frontend assets, or mailer.

## Required API

| Method | Path | Responsibility |
| --- | --- | --- |
| `POST` | `/encrypt` | Encode each depth-one value using the configured reversible algorithm |
| `POST` | `/decrypt` | Decode recognized encrypted values while preserving other values |
| `POST` | `/sign` | Produce a deterministic signature for a JSON value |
| `POST` | `/verify` | Verify that a signature belongs to a JSON value |

Detailed interpretations, tradeoffs, and observable invariants are recorded in
[the design decisions](docs/design-decisions.md).

## Technology

- Elixir 1.20.4
- Erlang/OTP 28.5
- Phoenix 1.8
- Bandit HTTP server
- Jason JSON encoder and decoder
- ExUnit and Phoenix connection tests

The exact Erlang and Elixir versions are pinned in `mise.toml`; dependency
versions are locked in `mix.lock`.

## Setup

First, ensure that
[mise is activated in your shell](https://mise.jdx.dev/getting-started.html#activate-mise).
Then install the runtimes pinned by this project:

```sh
mise install
```

Download the Mix dependencies:

```sh
mix setup
```

Create your local environment file from the tracked example:

```sh
cp .env.example .env
```

The local `.env` file is ignored by Git. With `mise` activated, its variables
are loaded automatically from the project configuration.

## Running locally

Start the Phoenix endpoint:

```sh
mix phx.server
```

The development server listens on <http://localhost:4000> by default.
`RIOT_SIGNING_SECRET` is shared by `/sign` and `/verify`; production must
provide a strong value through its runtime environment rather than through the
local `.env` file.

## Running with Docker

Docker Compose uses the same `.env` file, exposes the API on port 4000, and
mounts named volumes for Mix dependencies and build artifacts:

```sh
docker compose up --build
```

The development container binds Phoenix to `0.0.0.0` while direct local
development keeps the loopback-only default. Stop the container with:

```sh
docker compose down
```

Build the production release image with:

```sh
docker build --target final -t riot-json-crypto-api .
```

Run it with production secrets supplied only at runtime:

```sh
export RIOT_SIGNING_SECRET="$(openssl rand -hex 32)"
export SECRET_KEY_BASE="$(openssl rand -base64 48)"
docker run --rm -p 4000:4000 \
  -e RIOT_SIGNING_SECRET \
  -e SECRET_KEY_BASE \
  -e PHX_HOST=localhost \
  riot-json-crypto-api
```

## Tests and quality checks

Run the test suite:

```sh
mix test
```

Run the complete generated pre-commit workflow—compile with warnings treated
as errors, remove unused dependency locks, format the project, and run tests:

```sh
mix precommit
```

## Project structure

```text
config/             Phoenix and runtime configuration
docs/               Authored design documentation
lib/riot_json_crypto/       Framework-independent domain logic
lib/riot_json_crypto_web/   HTTP endpoint, router, and web adapters
test/               Unit and HTTP boundary tests
```

Base64 is a reversible encoding and provides no confidentiality. The exercise
uses it as a replaceable transformation rather than as production encryption.
