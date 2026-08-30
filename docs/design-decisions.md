# Design Decisions and Tradeoffs

This document explains the interpretation and design choices made for the [Riot backend take-home exercise](https://github.com/tryriot/take-home). It focuses on the reasoning behind the solution rather than on a particular implementation.

[Back to the project README](../README.md).

## 1. Interpreting depth one

For a top-level object, a property at depth one is one of its immediate values. Each such value is encoded as a whole; the operation does not recursively encode values inside a nested object.

```json
{
  "name": "John Doe",
  "contact": { "email": "john@example.com" }
}
```

Here, `name` and the complete `contact` object are encoded independently. For consistency with the requirement to accept any JSON payload, top-level array elements are treated as depth-one values. A top-level primitive has no child properties and is returned unchanged.

For example, consider a top-level array:

```json
[
  "John",
  30,
  { "email": "john@example.com" }
]
```

Its three elements are the depth-one values, so the conceptual result is:

```text
[
  Base64(marker + "\"John\""),
  Base64(marker + "30"),
  Base64(marker + "{\"email\":\"john@example.com\"}")
]
```

The `email` property is not encoded separately: the complete object is serialized and encoded as the third array element. By contrast, a top-level primitive such as `42` has no child value at depth one, so its input and output are both `42`. The same interpretation leaves top-level values such as `"hello"`, `true`, and `null` unchanged.

## 2. Base64 is encoding, not encryption

Base64 provides no confidentiality: anyone can decode it. The exercise explicitly selects Base64 for simplicity, so the endpoints use it as the requested reversible transformation. A production encryption feature would require an authenticated encryption algorithm and proper key management.

## 3. Serialize each value before encoding

Base64 operates on bytes, whereas JSON properties may contain strings, numbers, booleans, `null`, arrays, or objects. Each value is therefore serialized as JSON before it is converted to UTF-8 bytes and Base64-encoded.

This preserves the difference between values such as the number `30` and the string `"30"`:

```text
30    -> JSON text: 30
"30"  -> JSON text: "30"
```

After decoding, parsing the JSON text restores the original type and makes `decrypt(encrypt(payload))` return the original JSON value.

## 4. Distinguish encrypted values from ordinary strings

The decryption endpoint must preserve properties that were not encrypted. Bare Base64 cannot meet this requirement reliably because an ordinary user string may already be valid Base64. For example, `MzA=` is valid Base64 and decodes to the valid JSON value `30`; decoding every Base64-looking string would silently change user data.

Three representations were considered:

| Representation | Advantage | Drawback |
| --- | --- | --- |
| `Base64(JSON.stringify(value))` | Small and entirely Base64 | Cannot reliably distinguish encoded output from ordinary Base64-looking input |
| `base64:` + `Base64(JSON.stringify(value))` | Easy to recognize | The complete output is no longer valid Base64 because `:` is outside the Base64 alphabet |
| `Base64(marker + JSON.stringify(value))` | Recognizable after decoding, versionable, and the complete output remains valid Base64 | Adds a small amount of payload overhead |

The third representation is selected. A marker such as `riot:base64:v1:` is prepended to the serialized plaintext, and the complete sequence is then encoded:

```text
Base64("riot:base64:v1:" + JSON.stringify(value))
```

For the number `30`:

```text
serialized value:  30
marked plaintext:  riot:base64:v1:30
final output:      cmlvdDpiYXNlNjQ6djE6MzA=
```

The marker is envelope metadata, not a security mechanism. Its version component leaves room to change the representation later.

## 5. Decryption is conservative

A value is decrypted only when all of the following are true:

1. It is a well-formed Base64 string whose canonical re-encoding exactly matches the input.
2. Its decoded bytes start with the expected marker.
3. The content after the marker can be parsed as exactly one JSON value, which may itself be a string.

If any check fails, the original input string is returned unchanged. Missing markers and malformed values do not produce an endpoint error because the exercise explicitly requires unencrypted properties to remain unchanged. Non-string values also remain unchanged.

Each decryption removes exactly one envelope. If a value is encrypted twice, the first decryption returns the inner ciphertext as a string and the second returns the original value.

This policy favors data preservation. It cannot distinguish an unrelated value deliberately constructed with the same marker, but solving that would require authentication rather than Base64 alone.

## 6. Keep algorithms replaceable

The HTTP endpoints should depend on small encryption/decryption and signing/verification contracts rather than directly on Base64 or a specific HMAC function. This isolates transport concerns from algorithms and satisfies the exercise requirement that either algorithm be replaceable without significant changes to the rest of the application.

The format marker belongs to the Base64 implementation because it is part of that representation, not to the route handlers.

## 7. Sign the JSON value, not its source text

Two JSON objects can have the same value while listing their properties in different orders. Signing the raw request text would incorrectly give them different signatures. Before signing, the JSON value is converted to a deterministic representation:

- Object keys are sorted recursively.
- Array order is preserved because it is semantically meaningful.
- Primitive values use their JSON representation.

HMAC-SHA256 is a reasonable concrete choice: it is widely supported and produces a fixed-size signature. The signer and verifier share a secret, which must come from configuration rather than source code. A hexadecimal signature is easy to validate and inspect, although Base64 would be more compact.

## 8. Verification behavior

Verification applies the same canonicalization and HMAC process to the supplied `data`, then compares the expected and received signatures using a constant-time comparison. This avoids leaking information through ordinary early-exit string comparisons.

The endpoint returns the statuses required by the exercise:

- `204 No Content` when the signature is valid.
- `400 Bad Request` when the signature is invalid or the verification request is malformed.

## 9. Important invariants

The design should be tested primarily through these observable guarantees:

- Encrypting and then decrypting returns the original JSON payload, including value types.
- Every encrypted property value is a valid Base64 string.
- Ordinary text, ordinary Base64-looking strings, and malformed encoded strings survive decryption unchanged.
- Nested values at depth one round-trip as complete values.
- Reordering object properties does not change a signature.
- Reordering array elements does change a signature.
- A signature produced by `/sign` successfully verifies with `/verify` for the same JSON value.
- Modified data or a modified signature fails verification.
