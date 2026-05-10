---
name: umami-cloud-api-operations
description: Work with Umami Cloud transport and platform constraints. Use when configuring API keys, region-aware base URLs, Cloud-only rate-limit handling, hosted endpoint access, or Cloud-vs-self-hosted capability checks for apps built on top of Umami.
---

# Umami Cloud API Operations

Use this skill when the task is specifically about Umami Cloud behavior rather than generic Umami feature work.

## Base URLs

- Data API: `https://api.umami.is/v1`
- Optional regional paths: `/v1/us` and `/v1/eu`
- Collector: `https://cloud.umami.is/api/send`

For native apps, keep the data API host and collector host as separate configuration values. They are not interchangeable.

## Auth

Send the API key as:

- `x-umami-api-key: <api-key>`

This is different from self-hosted bearer-token auth.
Do not reuse that API key header for collector traffic to `https://cloud.umami.is/api/send`.

## Native iOS Risk Rule

Umami Cloud API keys are account-scoped credentials.

- Do not embed a long-lived Cloud API key in a consumer iOS app unless you have explicitly accepted that users can extract it.
- Prefer a server-side proxy or your own app backend for production customer-facing apps.
- Direct client-side Cloud API key usage is most defensible for internal tools, trusted enterprise distribution, local development, or narrowly scoped read-only prototypes.
- If you still ship direct key usage, store it in Keychain, support rotation, and treat revocation as an operational requirement.

## Limits

- 50 calls every 15 seconds per API key

Design the client to:

- back off on `429`
- avoid aggressive fan-out
- coalesce duplicate loads
- reuse cached responses when a screen is revisited quickly

## Not Allowed With Cloud API Keys

Official docs explicitly call out:

- `/me/password`
- `/users`
- `/users/*`

Also treat self-hosted-only admin flows as unavailable in Cloud.

## Current Drift To Account For

Official Cloud docs currently expose some routes that this checkout does not implement under `src/app/api`.

Examples from current docs and changelog include:

- `GET /api/websites/:websiteId/events/stats`
- `GET /api/websites/:websiteId/event-data`
- `POST /api/reports/performance`
- managed share APIs such as `POST /api/share` and `GET /api/websites/:websiteId/shares`

If you are building against Umami Cloud itself, follow the current docs.
If you are building against this checked-out server, prefer the repo routes.
Do not assume Cloud docs and this checkout are the same surface.

## Practical Guidance

- Keep Cloud credentials out of the normal user-login UI.
- Support key rotation.
- Make the selected region part of app configuration.
- Prefer one shared Cloud transport for all read APIs.
- Keep collector and data API hosts separate in your code.
- Separate Cloud API-key sessions from self-hosted bearer-token sessions in app state.
- Mark Cloud-only or docs-only endpoints as feature-gated instead of silently failing at runtime.

## Evolving Surface Rule

Cloud API routes change over time. Before hardcoding a less common route:

- check the current Cloud docs
- compare with the endpoint family docs
- note any mismatch in the implementation

The Cloud docs and endpoint-specific docs are not always perfectly aligned. When they disagree, prefer the endpoint-specific page and verify against the current route family before baking assumptions into the client.

## Official Sources

- https://docs.umami.is/docs/cloud/api-key
- https://docs.umami.is/docs/cloud/api-changelog
- https://docs.umami.is/docs/api
- https://docs.umami.is/docs/api/share
- https://docs.umami.is/docs/api/events
- https://docs.umami.is/docs/api/reports
- https://docs.umami.is/docs/api/sending-stats
