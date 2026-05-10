---
name: umami-swift-core
description: Build native Swift and iOS clients for Umami open source and hosted APIs. Use when creating shared URLSession transport, Codable models, environment selection, pagination, date-range filters, and auth-aware request builders for Umami Cloud or self-hosted Umami.
---

# Umami Swift Core

Use this skill when the task is primarily about transport, endpoint modeling, decoding, or environment setup for a native Apple client.

## Scope

- Shared networking and model primitives for Umami iOS.
- A single client surface that supports both self-hosted and Cloud.
- Query parameter encoding for Umami's REST shape.
- Error handling for auth, permission, paging, and rate limiting.
- Auth-mode separation for self-hosted bearer tokens, Cloud API keys, and legacy share-token access.

## Environment Model

Keep the deployment split at the transport layer, not the feature layer.

```swift
enum UmamiEnvironment: Equatable {
    case selfHosted(baseURL: URL)
    case cloud(region: CloudRegion?, apiKey: String)
    case legacyShare(baseURL: URL, websiteId: UUID, shareToken: String)
}

enum CloudRegion: String {
    case us
    case eu
}
```

Resolve base URLs like this:

- Self-hosted: `https://<instance>/api`
- Cloud: `https://api.umami.is/v1`
- Cloud regional override: `https://api.umami.is/v1/us` or `https://api.umami.is/v1/eu`

## Auth Rules

- Self-hosted uses `POST /api/auth/login`, then `Authorization: Bearer <token>`.
- Self-hosted token validation is `POST /api/auth/verify`.
- Cloud uses `x-umami-api-key`.
- Cloud API keys are rate limited to 50 calls per 15 seconds.
- The checked-out repo also supports legacy public-share reads via `x-umami-share-token`.

For iOS, keep these auth modes in different session types. Do not model them as a single interchangeable credential.

## Native Session Partitioning

For a real iOS app, separate "which server is this?" from "which credential do I have?":

```swift
struct UmamiInstanceID: Hashable, Codable {
    let kind: Kind
    let normalizedBaseURL: URL

    enum Kind: String, Codable {
        case selfHosted
        case cloud
        case legacyShare
    }
}
```

- Normalize self-hosted base URLs before storing credentials so `https://umami.example.com` and `https://umami.example.com/` do not create duplicate sessions.
- Scope Keychain items, caches, and offline state by instance ID.
- Never reuse a Cloud API-key session for a self-hosted bearer-token server.
- Never reuse a share session for an authenticated account session.
- Keep `x-umami-cache` continuity for collector traffic in a tracking store separate from read-API auth state.

## Request Shape

Model Umami requests around these recurring fields:

- `startAt` and `endAt` in Unix milliseconds.
- `timezone` as an IANA identifier.
- `page` and `pageSize` for paged collections.
- `search` for text filtering.
- `compare` for comparative series.
- Flat filter keys such as `path`, `referrer`, `title`, `query`, `browser`, `os`, `device`, `country`, `region`, `city`, `language`, `hostname`, `tag`, `event`, `segment`, and `cohort`.

Do not invent nested filter JSON for read endpoints. Umami read APIs expect query items for most filtering.

## Checked-Out Repo Caveat

Current official docs describe additional filter fields such as `distinctId` and UTM filters for some endpoint families.
This checkout's shared filter schemas do not currently accept those fields on normal read routes.

- Verify the exact route schema before exposing a filter in the app.
- Treat `distinctId` and `utm*` as capability-gated, not globally available.
- Reports use request-body filters, but in this checkout they are still validated against the shared filter schema.

## Implementation Pattern

Build around three layers:

1. `UmamiEnvironment`
2. `UmamiRequestBuilder`
3. Feature clients such as `WebsitesAPI`, `AnalyticsAPI`, `ReportsAPI`

Recommended responsibilities:

- `UmamiEnvironment`: host resolution and auth header policy.
- `UmamiRequestBuilder`: path joining, query item encoding, JSON bodies, shared headers.
- Feature APIs: endpoint-specific methods and response decoding.

For iOS, it is worth adding a fourth concern:

- `CredentialStore`: Keychain-backed storage and rotation for bearer tokens, share tokens, and any Cloud keys you intentionally keep on-device.

## Defaults That Work Well

- Use `JSONDecoder.dateDecodingStrategy = .iso8601`.
- Model count responses with reusable page wrappers.
- Treat `401` and `403` separately in UI state.
- Add retry with jitter only for `429` and transient `5xx` responses.
- Keep Cloud and self-hosted behavior behind the same async interface where possible.
- Use one configured `URLSession` per environment so caching, headers, and telemetry policy stay predictable.
- Keep one app-level registry of known instances so a user can switch between Cloud and multiple self-hosted servers without credential bleed.

## Version-Skew Rule

Umami's docs, API client docs, and checked-out server code can drift. When the route surface looks inconsistent:

- Prefer the checked-out repo for behavior tied to this workspace.
- Prefer official docs for Umami Cloud specifics.
- Flag the mismatch in code comments or notes instead of silently hardcoding assumptions.

## Local Anchors

- `src/app/api/auth/login/route.ts`
- `src/app/api/auth/verify/route.ts`
- `src/app/api/config/route.ts`
- `src/app/api/share/[shareId]/route.ts`
- `src/lib/request.ts`
- `src/lib/schema.ts`
- `src/lib/auth.ts`

## Official Sources

- https://docs.umami.is/docs/api
- https://docs.umami.is/docs/api/authentication
- https://docs.umami.is/docs/cloud/api-key
- https://docs.umami.is/docs/api/share
- https://docs.umami.is/docs/api/api-client
