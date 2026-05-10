---
name: umami-links-and-pixels
description: Build on Umami tracked links and tracking pixels. Use when creating short-link management, pixel management, campaign attribution assets, slug workflows, team-scoped links or pixels, and iOS tooling that works with Umami link or pixel APIs.
---

# Umami Links And Pixels

Use this skill when the task is about managed tracking assets rather than normal website analytics.

## Core Surfaces

- `/links`
- `/links/:linkId`
- `/pixels`
- `/pixels/:pixelId`
- `/teams/:teamId/links`
- `/teams/:teamId/pixels`

The team-scoped link and pixel routes in this checkout are list endpoints only.
Creation still happens through `/links` and `/pixels` with optional `teamId`.

## What They’re For

- Links let you create tracked redirect assets with a `slug`.
- Pixels let you create tracked pixel assets with a `slug`.
- Both can belong to a user or a team.

## iOS Use Cases

- build admin or setup screens for marketing assets
- let users browse and manage their tracked slugs
- support campaign configuration alongside analytics dashboards
- feed a mobile app that manages a self-hosted or Cloud Umami workspace

## Data Shape Notes

Current repo routes show:

- links require `name`, `url`, and `slug`
- pixels require `name` and `slug`
- both support optional `teamId`
- both are paged and searchable in list views
- updates can return slug-conflict errors that should be surfaced cleanly in the app

Current official docs also document a minimum 8-character slug for both links and pixels.
This checkout enforces that minimum on update routes, but the create routes are looser today.

- Validate a minimum 8-character slug in the client anyway.
- Surface uniqueness errors from the server as a second line of defense.
- Do not copy the create-route looseness into a native admin UI as if it were the intended contract.

## Product Guidance

- validate slug uniqueness and show helpful conflict messages
- separate personal assets from team assets in the UI
- do not mix link creation flows into website creation flows
- treat these as operational resources, not analytics read endpoints
- if you support both Cloud and self-hosted servers, feature-check team-scoped list helpers instead of assuming every deployment exposes them identically

## Local Anchors

- `src/app/api/links/route.ts`
- `src/app/api/links/[linkId]/route.ts`
- `src/app/api/pixels/route.ts`
- `src/app/api/pixels/[pixelId]/route.ts`
- `src/app/api/teams/[teamId]/links/route.ts`
- `src/app/api/teams/[teamId]/pixels/route.ts`

## Official Sources

- https://docs.umami.is/docs/api/links
- https://docs.umami.is/docs/api/pixels
- https://docs.umami.is/docs/api/teams
