---
name: umami-ios-querying
description: Query Umami analytics into a native iOS app. Use when implementing website lists, stats cards, metrics tables, pageview series, events, sessions, event-data drilldowns, realtime reads, paging, filtering, and comparative analytics for Umami Cloud or self-hosted Umami.
---

# Umami iOS Querying

Use this skill for read-heavy analytics features in `Umami iOS`.

## Main Endpoint Families

- Websites: `/websites`, `/websites/:websiteId`
- Website stats: `/websites/:websiteId/active`, `/daterange`, `/pageviews`, `/events/series`, `/metrics`, `/metrics/expanded`, `/stats`, `/values`
- Events and event data: `/websites/:websiteId/events`, `/event-data/*`
- Sessions and session data: `/websites/:websiteId/sessions`, `/session-data/*`
- Saved reports by website: `/websites/:websiteId/reports`
- Export helpers: `/websites/:websiteId/export`
- Realtime: `/realtime/:websiteId`

The checked-out repo also includes useful detail routes that are worth modeling explicitly:

- `/websites/:websiteId/sessions/:sessionId`
- `/websites/:websiteId/sessions/:sessionId/activity`
- `/websites/:websiteId/sessions/:sessionId/properties`
- `/websites/:websiteId/sessions/stats`
- `/websites/:websiteId/sessions/weekly`
- `/websites/:websiteId/event-data/:eventId`

## Query Design Rules

- Use typed query structs for every endpoint family.
- Keep filters flat and explicit.
- Encode `startAt` and `endAt` as milliseconds.
- Keep `page` and `pageSize` optional so you can reuse the same request object for compact cards and full tables.
- Use `/values` only for checkout-supported field pickers instead of hardcoding option lists.
- Separate query-item endpoints from request-body report runners in your Swift client.

For this checkout, `/values` is narrower than the current docs surface. It only accepts the `fieldsParam` set from `src/lib/schema.ts`, so do not use it as a generic source for:

- `distinctId`
- UTM filters
- `channel`
- `domain`
- `screen`
- saved segment or cohort lists

## Recommended Model Groups

- `WebsiteSummary`
- `WebsiteStats`
- `MetricRow`
- `ExpandedMetricRow`
- `PageviewPoint`
- `SessionSummary`
- `SessionDetail`
- `EventSummary`
- `EventPropertyRow`
- `RealtimeSnapshot`

## High-Value Screens

Build these first:

1. website picker
2. overview stats
3. trends and compare screen backed by `/pageviews`
4. top metrics by type
5. realtime board
6. sessions list with detail drilldown

That gives a useful iOS analytics client before saved reports or admin tooling.

## Filters To Support Early

- `path`
- `referrer`
- `title`
- `query`
- `browser`
- `os`
- `device`
- `country`
- `region`
- `city`
- `language`
- `hostname`
- `event`
- `tag`
- `segment`
- `cohort`

Do not expose `distinctId` or UTM filters as generic read-endpoint filters for this checkout. Current docs mention them for some endpoint families, but the checked-out shared filter schemas do not currently accept them on the normal website read routes.

## Supporting Workflows

- Use `/daterange` to discover the actual available data window before defaulting a chart range.
- Use `/active` for a lightweight "currently active" badge instead of polling full realtime views.
- Use `/websites/:websiteId/reports` for saved report discovery in a website-scoped UI.
- Use `/sessions/stats` for compact summary cards and `/sessions/weekly` for weekday or heatmap-style views instead of deriving both from the raw session list.
- Use `/sessions/:sessionId` plus `/activity` and `/properties` for a proper drilldown screen.
- Use `/session-data/properties` and `/session-data/values` for identify-style trait exploration instead of trying to infer that from session rows alone.
- Use `/event-data/:eventId` only after the user has already selected a concrete row from events or event-data lists.

## Pageviews and Compare

`/websites/:websiteId/pageviews` is the checkout's best native time-series endpoint for an overview or compare screen.

- It returns both pageviews and sessions.
- It accepts `compare`, and the route currently supports `prev` and `yoy`.
- Use it for trend charts before reaching for heavier report runners.
- Keep `/stats` for headline cards and `/metrics*` for ranked tables.

## Export Note

The checked-out repo exposes `GET /websites/:websiteId/export` and returns a base64-encoded zip payload containing CSV files. Treat that as repo-specific behavior and do not assume it matches the current Umami Cloud export UX exactly.

## Realtime Guidance

Realtime is read-mostly and short-window:

- poll conservatively
- cancel refresh work when the screen disappears
- merge totals and event feed into a single view model
- avoid reloading heavyweight historical endpoints on the same cadence

## Version-Skew Note

Official docs, the public API client docs, and the server checkout do not always match exactly. If an endpoint family looks off:

- check `src/app/api`
- compare to the docs page for that family
- prefer the repo when building against this checkout

Current docs and changelog already describe newer routes such as:

- `GET /api/websites/:websiteId/events/stats`
- `GET /api/websites/:websiteId/event-data`

Those are not present in this checkout, so do not promise them in a client targeting this repo without feature detection.

Current docs also document broader filter support like `distinctId`, `utmSource`, `utmMedium`, `utmCampaign`, `utmContent`, and `utmTerm` on several read families.
This checkout's shared read-route schemas do not currently accept those fields on the normal website read endpoints, so keep them feature-gated.

## Local Anchors

- `src/app/api/websites/route.ts`
- `src/app/api/websites/[websiteId]/active/route.ts`
- `src/app/api/websites/[websiteId]/daterange/route.ts`
- `src/app/api/websites/[websiteId]/pageviews/route.ts`
- `src/app/api/websites/[websiteId]/events/route.ts`
- `src/app/api/websites/[websiteId]/events/series/route.ts`
- `src/app/api/websites/[websiteId]/metrics/route.ts`
- `src/app/api/websites/[websiteId]/metrics/expanded/route.ts`
- `src/app/api/websites/[websiteId]/event-data/[eventId]/route.ts`
- `src/app/api/websites/[websiteId]/event-data/events/route.ts`
- `src/app/api/websites/[websiteId]/event-data/fields/route.ts`
- `src/app/api/websites/[websiteId]/event-data/properties/route.ts`
- `src/app/api/websites/[websiteId]/event-data/stats/route.ts`
- `src/app/api/websites/[websiteId]/event-data/values/route.ts`
- `src/app/api/websites/[websiteId]/sessions/[sessionId]/route.ts`
- `src/app/api/websites/[websiteId]/sessions/[sessionId]/activity/route.ts`
- `src/app/api/websites/[websiteId]/sessions/[sessionId]/properties/route.ts`
- `src/app/api/websites/[websiteId]/values/route.ts`
- `src/app/api/websites/[websiteId]/stats/route.ts`
- `src/app/api/websites/[websiteId]/sessions/route.ts`
- `src/app/api/websites/[websiteId]/sessions/stats/route.ts`
- `src/app/api/websites/[websiteId]/sessions/weekly/route.ts`
- `src/app/api/websites/[websiteId]/session-data/properties/route.ts`
- `src/app/api/websites/[websiteId]/session-data/values/route.ts`
- `src/app/api/websites/[websiteId]/reports/route.ts`
- `src/app/api/websites/[websiteId]/export/route.ts`
- `src/app/api/realtime/[websiteId]/route.ts`

## Official Sources

- https://docs.umami.is/docs/api/websites
- https://docs.umami.is/docs/api/website-stats
- https://docs.umami.is/docs/api/events
- https://docs.umami.is/docs/api/sessions
- https://docs.umami.is/docs/api/realtime
- https://docs.umami.is/docs/cloud/api-changelog
