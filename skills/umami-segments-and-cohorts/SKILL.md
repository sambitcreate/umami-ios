---
name: umami-segments-and-cohorts
description: Build with Umami segments and cohorts. Use when implementing saved filters, reusable audience definitions, cohort-backed analytics queries, dynamic filter value pickers, or website-level segment CRUD for Umami apps.
---

# Umami Segments And Cohorts

Use this skill when the task is about saved audience definitions and reusable analytics filters.

## Core Surfaces

- `/websites/:websiteId/segments`
- `/websites/:websiteId/segments/:segmentId`
- `/websites/:websiteId/values`

## Current Repo Behavior

The checked-out repo supports segment CRUD with:

- `type`
- `name`
- `parameters`

`type` can represent normal segments or cohorts.

Important checkout caveat:

- The route handler for `/values` has code intended to support segment and cohort lookups.
- But the checked-out request schema for that endpoint currently validates `type` against normal field values only.

For this repo, do not rely on `/values?type=segment` or `/values?type=cohort` unless that route is fixed first.

## What This Skill Owns

Use this skill for saved audience-definition workflows:

- listing saved segments and cohorts
- creating or editing a saved definition
- applying a saved segment or cohort ID to downstream stats, sessions, events, and reports
- presenting segment and cohort management screens in a native app

If the task is just "which read endpoint should I call?", prefer `umami-ios-querying`.
If the task is "how should the saved definitions behave and be modeled in the app?", stay here.

## App Patterns

- build a saved-filter picker for analysts
- let users save current filter state as a segment
- surface cohorts separately from normal segments
- reuse segment IDs in downstream stats, events, sessions, and report requests
- make cohort creation explicit about date range and action semantics, since cohorts are not just named filters

## Modeling Guidance

- keep segment definitions as opaque server-owned payloads
- model segment metadata separately from analytics query state
- treat segment and cohort selection as top-level filter context in the app
- cache the list responses, not the internal `parameters` shape
- when applying one of these saved definitions, pass the resulting `segment` or `cohort` UUID through normal query models instead of flattening the saved filters on-device

## UX Guidance

- show whether a saved item is a segment or cohort
- do not force users to rebuild complex filters manually
- populate ordinary field selectors from `/values` when possible
- populate saved segment and cohort pickers from `/segments?type=segment` and `/segments?type=cohort`
- expect updates and deletes to be permission-gated by website ownership
- explain that cohorts include a date-windowed user action, while segments are reusable filter bundles

## Local Anchors

- `src/app/api/websites/[websiteId]/segments/route.ts`
- `src/app/api/websites/[websiteId]/segments/[segmentId]/route.ts`
- `src/app/api/websites/[websiteId]/values/route.ts`
- `src/lib/constants.ts`
- `src/lib/request.ts`

## Official Sources

- https://docs.umami.is/docs/segments
- https://docs.umami.is/docs/cohorts
- https://docs.umami.is/docs/api/website-stats
- https://docs.umami.is/docs/api/events
- https://docs.umami.is/docs/api/sessions
- https://docs.umami.is/docs/api/reports
