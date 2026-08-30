# Riot API agent guidance

## Project context

This repository is a deliberately small Phoenix JSON API for the
[Riot backend take-home exercise](https://github.com/tryriot/take-home). Read
`README.md` and `docs/design-decisions.md` before proposing implementation
changes.

The project uses Elixir and Phoenix with Bandit. It intentionally has no Ecto,
HTML, LiveView, frontend assets, mailer, or database.

## Collaboration

- Default to teaching in small, verifiable steps. Explain the purpose of a
  command or code change before asking the user to type it.
- Do not implement application behavior unless the user explicitly asks an
  agent to make that change. The user is learning Elixir by writing the
  implementation themselves.
- Keep suggestions scoped to the exercise. Do not introduce production
  infrastructure or speculative abstractions.
- Do not silently change an interpretation recorded in
  `docs/design-decisions.md`; discuss the tradeoff first and update the document
  when a decision changes.

## Architecture

- Keep transport concerns in `RiotApiWeb`: routing, HTTP validation, status
  codes, and JSON responses.
- Keep encryption, decryption, signing, verification, and canonicalization in
  `RiotApi`, without dependencies on Phoenix connection structs.
- Keep the reversible transformation and signing algorithms behind small,
  explicit contracts so either implementation can be replaced independently.
- Treat Base64 as an encoding, not as secure encryption.
- Read secrets from runtime configuration. Never commit credentials or secret
  defaults intended for production.
- Do not add a dependency when Elixir, Erlang/OTP, Phoenix, or an existing
  dependency already provides the required operation.

## Elixir and Phoenix conventions

- Use pattern matching and tagged return values such as `{:ok, value}` and
  `{:error, reason}` for operations that can fail.
- Do not create atoms from user-controlled strings with `String.to_atom/1`.
- Put one top-level module in each source file.
- Keep functions focused and name predicates with a trailing `?`; reserve an
  `is_` prefix for guards.
- Define API routes in `RiotApiWeb.Router` and test them through the generated
  `RiotApiWeb.ConnCase` support.
- `Plug.Parsers` nests every valid top-level JSON value under the `"_json"` key;
  unwrap that value once at the HTTP boundary before calling domain code.
- Preserve arbitrary valid JSON types rather than assuming every payload is an
  object.

## Tests and validation

- Test observable behavior and round-trip invariants, including malformed and
  Base64-looking input, rather than testing private implementation details.
- Add focused unit tests for domain modules and connection tests for the HTTP
  boundary.
- Avoid timing-based tests and `Process.sleep/1`. Use synchronization or
  process monitoring when asynchronous behavior genuinely needs testing.
- Run a focused test while developing, then run `mix precommit` before calling
  a change complete.

## Documentation

- Store authored project documentation in `docs/`.
- `doc/` is reserved for generated ExDoc output and is intentionally ignored.
- Keep the README limited to current project usage and high-level orientation;
  keep detailed reasoning and tradeoffs in `docs/design-decisions.md`.
