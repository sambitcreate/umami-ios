---
name: umami-website-management
description: Manage Umami websites from an app. Use when implementing website creation, editing, deletion, reset flows, share ID management, ownership transfer, or website settings screens for self-hosted or Umami Cloud workspaces.
---

# Umami Website Management

Use this skill when the task is about managing website resources, not just reading their analytics.
Keep this skill focused on website CRUD and settings. Use `umami-workspaces-and-sharing` for team membership and public share-session behavior.

## Core Surfaces

- `/websites`
- `/websites/:websiteId`
- `/websites/:websiteId/reset`
- `/websites/:websiteId/transfer`

Current official docs document the first three families, but they do not currently list `/websites/:websiteId/transfer` on the Websites page.
Treat transfer as checked-out-repo behavior rather than a guaranteed portable API contract.

## Current Repo Behavior

Website create and update flows currently expose fields such as:

- `name`
- `domain`
- `shareId`
- `teamId`
- optional explicit `id` on create

Reset is a dedicated `POST` endpoint. Transfer is also a dedicated `POST` endpoint and moves ownership between a personal user and a team.

## Product Guidance

- treat reset as a destructive settings action with confirmation
- keep share-ID editing separate from normal website-name editing
- make ownership transfer explicit and role-aware
- handle team-owned and user-owned websites as different states in settings UI

## Cloud Note

The checked-out repo has Cloud-specific website-count limits when `CLOUD_MODE` is enabled for non-team websites. Treat that as instance behavior to detect rather than a universal rule for every Umami deployment.

## Share Note

This checkout still supports simple website `shareId` management on the website resource itself.
Current official docs also describe a newer managed share-page API family.

- If you are targeting this checkout, `shareId` is the local website-setting behavior to model.
- If you are targeting current Cloud/docs behavior, evaluate the managed share APIs separately under `umami-workspaces-and-sharing`.

## Boundary Rule

This skill owns:

- `/websites`
- `/websites/:websiteId`
- `/websites/:websiteId/reset`
- `/websites/:websiteId/transfer`
- checkout-specific `shareId` editing on the website resource

This skill does not own:

- public share-session bootstrap
- managed share-page CRUD from current docs
- team membership management

## Typical App Screens

- website list and create flow
- website settings
- share settings
- reset analytics confirmation
- transfer ownership sheet

## Local Anchors

- `src/app/api/websites/route.ts`
- `src/app/api/websites/[websiteId]/route.ts`
- `src/app/api/websites/[websiteId]/reset/route.ts`
- `src/app/api/websites/[websiteId]/transfer/route.ts`
- `src/permissions/website.ts`

## Official Sources

- https://docs.umami.is/docs/api/websites
- https://docs.umami.is/docs/api/share
- https://docs.umami.is/docs/api/teams
- https://docs.umami.is/docs/cloud/api-changelog
