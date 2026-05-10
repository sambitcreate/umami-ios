---
name: umami-ios-tracking
description: Send analytics from a native iOS app to Umami. Use when implementing pageview mapping, custom events, identify calls, distinct IDs, payload shaping, offline queueing, cache header reuse, and privacy-safe event delivery to Umami Cloud or self-hosted Umami.
---

# Umami iOS Tracking

Use this skill when the task is about collecting analytics from an iPhone or iPad app rather than querying analytics back out.

## Collector Endpoints

- Self-hosted ingestion: `POST /api/send`
- Cloud ingestion: `POST https://cloud.umami.is/api/send`

The collector does not require the normal authenticated data API token.

## Confirmed Payload Rules

Current server code accepts:

- `type: "event"`
- `type: "identify"`

Official sending-stats docs still describe `event` as the only public type. Treat `identify` support as checked-out-repo behavior that may not exist on every Umami deployment.

The payload must include exactly one of:

- `website`
- `link`
- `pixel`

For a normal app integration, use `website`.

## iOS Mapping

Translate native app concepts like this:

- screen view -> pageview event with `url` set to a stable route-like string such as `/home` or `/settings/profile`
- custom interaction -> `name`
- user identity -> `id`
- user or session traits -> `data`
- app display name or visible title -> `title`
- app bundle host, tenant, or logical host -> `hostname`

Keep route strings stable. Avoid tying analytics URLs to localized copy.

## Response Handling

The collector returns:

- `cache`
- `sessionId`
- `visitId`

Persist the `cache` token and send it back as `x-umami-cache` on later calls. This lets the server keep session and visit continuity.

## Timestamp Rule For Offline Replay

In this checkout, `payload.timestamp` is interpreted in Unix seconds, not milliseconds.

- Convert `Date` values deliberately before replaying queued events.
- Do not reuse the millisecond timestamp style used by many Umami read endpoints.
- If you mix units, event ordering and visit expiry will be wrong.

## Batch Replay

The checked-out repo also exposes `POST /api/batch`.

Use it when:

- replaying an offline queue
- flushing a burst of buffered events
- preserving shared collector headers during bulk send

The batch route internally replays send payloads, returns aggregate error details, and keeps the first successful `cache` token for follow-up requests.

## Delivery Guidance

- Queue events locally when offline.
- Flush on foreground transitions and before app suspension when feasible.
- Retry with capped exponential backoff.
- Preserve original timestamps when replaying queued events, and store them in a unit-safe way.
- Always send a useful `User-Agent`.
- Keep collector request construction in one place so `x-umami-cache`, `User-Agent`, and source IDs are consistent.

## Privacy Guidance

- Do not send PII by default.
- Treat `identify` data as sensitive application data.
- Keep `distinctId` stable only if your product really needs cross-session identity.
- Make event names product-level, not user-level.

## Server Behaviors Worth Remembering

The checked-out collector code also:

- derives session and visit IDs
- extracts UTM fields and click IDs from the submitted URL
- ignores obvious bots unless bot checks are disabled
- supports `REMOVE_TRAILING_SLASH`
- can sit behind a custom self-hosted collection path via `COLLECT_API_ENDPOINT`

## Native iOS Modeling

Useful Swift-side separation:

- `TrackingEvent` for pageviews and custom events
- `IdentifyPayload` for session traits and optional distinct identity
- `CollectorSession` for the rolling `cache`, `sessionId`, and `visitId`
- `OfflineEnvelope` for durable replay-safe storage

Do not leak raw collector JSON shapes into SwiftUI views.

## Practical Rule

If the task is "wire analytics into the app," favor a small typed tracking layer over sprinkling raw JSON calls throughout SwiftUI views.

## Local Anchors

- `src/app/api/send/route.ts`
- `src/app/api/batch/route.ts`
- `src/lib/constants.ts`

## Official Sources

- https://docs.umami.is/docs/api/sending-stats
- https://docs.umami.is/docs/track-events
- https://docs.umami.is/docs/tracker-functions
- https://docs.umami.is/docs/environment-variables
