---
name: umami-swiftui-dashboards
description: Build SwiftUI dashboards and analytics surfaces for Umami data. Use when designing overview cards, charts, realtime boards, session drilldowns, filter bars, loading states, and role-aware empty states for a native Umami iOS app.
---

# Umami SwiftUI Dashboards

Use this skill when the work is primarily UI and product experience, not transport.

This skill is intentionally about screen composition and interaction design.
Use `umami-ios-querying` for exact route selection and payload modeling, then come here to turn that data into a good mobile analytics experience.

## Default Product Bias

Favor a read-only, mobile-first dashboard before trying to mirror every desktop Umami screen.

## Suggested Screen Order

1. account and workspace picker
2. website overview
3. trends and compare screen
4. realtime screen
5. sessions explorer
6. reports and saved views

## Route-To-Screen Mapping

- website overview: `/websites/:websiteId/stats`, `/active`, `/daterange`
- trends and compare screen: `/pageviews`, `/events/series`, `/metrics`, `/metrics/expanded`
- realtime screen: `/realtime/:websiteId`
- sessions explorer: `/sessions`, `/sessions/stats`, `/sessions/weekly`
- session detail: `/sessions/:sessionId`, `/sessions/:sessionId/activity`, `/sessions/:sessionId/properties`
- event drilldown: `/events`, `/event-data/events`, `/event-data/:eventId`, `/event-data/properties`, `/event-data/values`
- identify and trait drilldown: `/session-data/properties`, `/session-data/values`
- saved report browser: `/websites/:websiteId/reports` and the report-runner routes handled by `umami-reports-api`

## UI Principles

- Keep primary cards above the fold: visitors, visits, pageviews, bounce rate, total time.
- Treat filters as first-class state, not an afterthought.
- Use progressive disclosure for sessions and event-property detail.
- Separate historical analytics from realtime polling.
- Make auth and permission failures legible in the UI.

## Charting Guidance

- Line or area charts for `pageviews` and `sessions`.
- Horizontal ranked bars for `metrics`.
- Compact heatmap or weekday matrix for weekly session activity.
- Rolling event feed plus counters for realtime.

## State Management

- Put transport in a shared client, not inside views.
- Use one observable object per major screen.
- Keep query state serializable so links, tests, and previews can reconstruct a screen.
- Debounce filter changes before issuing network requests.
- Keep realtime polling isolated from historical screen state so a live screen does not thrash the rest of the app.

## Empty and Error States

Handle these distinctly:

- no websites
- no data in selected range
- private instance or limited permissions
- invalid share link
- expired auth
- rate limited Cloud calls

## Public and Shared Modes

If the user is in a share flow, suppress editing affordances and keep the UI obviously read-only.

For this checkout, share mode means a separate session backed by `x-umami-share-token`, not a normal logged-in account.

## Companion Skills

- Use `umami-swift-core` for shared client plumbing.
- Use `umami-ios-querying` for endpoint selection and models.
- Use `umami-workspaces-and-sharing` for multi-workspace and public-share behavior.

## Official Sources

- https://docs.umami.is/docs/api/websites
- https://docs.umami.is/docs/api/website-stats
- https://docs.umami.is/docs/api/realtime
- https://docs.umami.is/docs/api/sessions
