---
name: umami-reports-api
description: Build against Umami's reports APIs from a native app. Use when implementing saved reports, ad hoc report runners, funnels, attribution, retention, revenue, UTM analysis, breakdowns, journeys, and report-specific filtering for Umami Cloud or self-hosted Umami.
---

# Umami Reports API

Use this skill when the task is about Umami reports rather than low-level metrics or session tables.

## Report Surface

The checked-out repo exposes:

- saved report CRUD via `/reports`
- ad hoc report runners such as:
  - `/reports/attribution`
  - `/reports/breakdown`
  - `/reports/funnel`
  - `/reports/goal`
  - `/reports/journey`
  - `/reports/retention`
  - `/reports/revenue`
  - `/reports/utm`

Current official docs also describe:

- `/reports/performance`

That route is not present in this checkout under `src/app/api/reports`.

## Filters

Reports support rich filter bodies. Common fields include:

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
- `tag`
- `event`
- `segment`
- `cohort`

Current docs also mention `distinctId` and UTM filter fields for reports.
Do not assume they work against this checkout just because they appear in the docs. In this repo, report filters are still validated against the shared filter schema, which does not currently include those fields.

## iOS Guidance

- Use request-body models, not query-item models, for report runners.
- Keep each report type in a dedicated request and response model pair.
- Expect different payload shapes across report types.
- Build report screens lazily; do not preload every report on app launch.
- Treat `performance` as a docs-only capability until the connected server proves it exists.
- Feature-gate revenue `compare` support by server capability if you target both Cloud and this checkout.

## Saved Reports

Treat saved reports as user-authored assets:

- list them by website
- open one report at a time
- only expose editing if the current account can update it

## Drift Warning

The report surface is one of the easiest places for docs and code to drift. If a path looks wrong:

- compare the docs page
- compare `src/app/api/reports`
- prefer the checked-out repo for this workspace
- leave a note instead of silently reshaping the API

Current examples of drift:

- current docs list `POST /api/reports/performance`
- current docs describe extra report filters that this checkout does not validate
- current docs describe `compare` on revenue reports

Those are exactly the cases where a native client should avoid overcommitting its public UI.

## Local Anchors

- `src/app/api/reports/route.ts`
- `src/app/api/reports/[reportId]/route.ts`
- `src/app/api/reports/attribution/route.ts`
- `src/app/api/reports/breakdown/route.ts`
- `src/app/api/reports/funnel/route.ts`
- `src/app/api/reports/goal/route.ts`
- `src/app/api/reports/journey/route.ts`
- `src/app/api/reports/retention/route.ts`
- `src/app/api/reports/revenue/route.ts`
- `src/app/api/reports/utm/route.ts`

## Official Sources

- https://docs.umami.is/docs/api/reports
- https://docs.umami.is/docs/api/websites
- https://docs.umami.is/docs/api/website-stats
- https://docs.umami.is/docs/cloud/api-changelog
