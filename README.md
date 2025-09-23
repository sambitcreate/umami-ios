# Umami Analytics (iOS)

A SwiftUI iOS client for Umami analytics (self‑hosted and Umami Cloud).

**Date:** September 23, 2025

## What Changed Today

- Added server selection on the login screen:
  - Options: `Umami.is` (Cloud) or `Self Hosted`.
  - Cloud hides the URL field and shows an `API Key` field.
  - Self‑hosted asks for `Server URL`, `Username`, and `Password`.
- Implemented Umami Cloud authentication via API key:
  - Sends header `x-umami-api-key` against the Cloud base.
  - Normalizes paths so existing `/api/...` calls map to Cloud `/v1/...`.
- Persisted auth mode and secrets:
  - Keychain: bearer token (self‑hosted) and Cloud API key.
  - UserDefaults: last server URL and server type (`cloud` | `self`).
- Kept existing self‑hosted bearer‑token flow unchanged.

### Networking & API compatibility
- Fixed URL building so query strings are not percent‑encoded as `%3F` (prevents 404s from paths like `/metrics%3FstartAt=...`).
- Websites listing now requests a larger page size to avoid truncation:
  - `GET /api/websites?page=1&pageSize=1000`.
- Metrics fetching reworked to match the documented API shape:
  - Calls `GET /api/websites/{id}/metrics` with required `type` per group (`url`, `referrer`, `browser`, `os`, `device`, `country`).
  - Adds `limit=50` to keep payloads reasonable.
  - Time‑series uses `GET /api/websites/{id}/pageviews` for `pageviews` and `sessions`.
  - All requests use millisecond `startAt/endAt` plus `unit` and `timezone` (from device).

### Caching & UX (stale‑while‑revalidate)
- Websites: show cached list immediately; spinner only on cold start.
- Stats: load cached stats first per website/period; refresh in background.
- Metrics: load cached pageviews/sessions and Top Pages/Referrers immediately; refresh in background.
- Added caches for Browsers, Devices, and Countries so those sections render instantly on cold start.
- Added subtle “Last updated …” under the period picker (caption2, 40% opacity) indicating cache/network freshness.

### Core Data
- New entity: `UmamiWebsiteMetrics` with binary blobs for:
  - `pageviewsData`, `sessionsData`, `pagesData`, `referrersData`, `browsersData`, `devicesData`, `countriesData`.
- Enabled lightweight migration in `Persistence.swift` so existing installs upgrade automatically.

## How To Use

- Choose a server type on the login screen:
  - Umami.is (Cloud): paste your API key from Umami Cloud → Settings → API Keys, then Sign In.
  - Self Hosted: enter the full server URL (e.g., `https://analytics.example.com`), username, and password.
- The app saves your choice and credentials securely and restores them on launch.

## Implementation Notes

- Cloud Mode
  - Base host is set to `https://api.umami.is` for API calls.
  - The client rewrites paths:
    - `/api/v1/...` → `/v1/...`
    - `/api/...` → `/v1/...`
    - `/v1/...` passes through
  - `x-umami-api-key` is applied instead of `Authorization: Bearer ...`.
  - Identity check uses `/v1/me`.
- Self‑Hosted Mode
  - Logs in via `POST /api/auth/login`, stores the returned bearer token, and calls self‑hosted `/api/...` endpoints.

## Files Touched

- UI
  - `Umami Analytics/Views/LoginView.swift` — server‑type picker, conditional fields, API‑key login branch.
- Auth
  - `Umami Analytics/Auth/AuthManager.swift` — Cloud API‑key login (`loginWithAPIKey`), Keychain storage for API key, server‑type persistence, bootstrap on launch.
- Networking
  - `Umami Analytics/Networking/APIClient.swift` — Cloud mode (`configureForCloud`), `x-umami-api-key` header, Cloud path normalization, `verifyToken()` handles Cloud `/v1/me`.
  - Query handling preserves `?` in paths; do not use `appendingPathComponent` for paths with queries.
  - Websites list uses `pageSize=1000`.
  - Metrics pipeline:
    - `GET /api/websites/{id}/metrics?type=<group>&startAt=...&endAt=...&unit=...&timezone=...&limit=50` for url/referrer/browser/os/device/country.
    - `GET /api/websites/{id}/pageviews?startAt=...&endAt=...&unit=...&timezone=...` for series.

## Persistence Keys

- Keychain
  - `umami.auth.token` — self‑hosted bearer token
  - `umami.cloud.api.key` — Umami Cloud API key
- UserDefaults
  - `umami.server.url` — last used base URL
  - `umami.server.type` — `cloud` or `self`
  - Existing feature flags (e.g., endpoint format hints) remain unchanged

## Performance & UX

- Stale‑while‑revalidate keeps screens responsive; cached data renders instantly, network updates replace it quietly.
- The detail view spinner only appears on a true cold start (no cached stats/metrics).

## Notes & Caveats

- Cloud login uses API key (recommended by Umami) rather than username/password.
- The login UI shows `https://cloud.umami.is` as the Cloud host label, but API requests target `https://api.umami.is/v1/...` under the hood.
- Existing users with a stored self‑hosted URL are auto‑selected into Self Hosted; saved Cloud setups are auto‑selected into Umami.is.

## Endpoint Reference

See `api-reference.md` for endpoint shapes and parameters, particularly:
- Websites API (pagination via `page`, `pageSize`).
- Website statistics and metrics: `startAt`, `endAt`, `unit`, `timezone`, and `type` for metrics groups.

## Quick Test Steps

- Cloud: Select `Umami.is` → paste API key → Sign In → confirm websites load.
- Self‑hosted: Select `Self Hosted` → enter URL + username/password → Sign In → confirm websites load.

For endpoint reference and Cloud notes, see `api-reference.md` and `troubleshoot.md`.
