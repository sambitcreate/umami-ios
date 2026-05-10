---
name: umami-workspaces-and-sharing
description: Handle Umami teams, workspace switching, website ownership, and public share flows. Use when building team-aware navigation, share-link access, permissions-aware website lists, and read-only analytics experiences on top of Umami APIs.
---

# Umami Workspaces And Sharing

Use this skill when the problem is about who can see what, or how a native app should behave across personal, team, and public contexts.

## Main Surfaces

- `/me`
- `/me/teams`
- `/me/websites`
- `/teams/*`
- `/teams/join`
- share-link bootstrap flows

## Team and Workspace Endpoints

This checkout and the current docs both support concrete workspace-management routes worth modeling directly:

- `/teams` for list and create
- `/teams/:teamId` for detail, update, and delete
- `/teams/:teamId/users` for member list and add
- `/teams/:teamId/users/:userId` for member detail, role update, and removal
- `/teams/:teamId/websites` for team website lists
- `/teams/join` for access-code join flows
- `/me/websites?includeTeams=true` for a combined website picker

If you are building user-account management or instance-wide admin screens, hand that work to `umami-selfhosted-auth-admin` instead of broadening this skill.

## Workspace Rules

- Personal and team-owned websites are different ownership modes.
- Website creation and updates are permission-based, not just authenticated.
- Team-aware website lists often need `includeTeams=true`.
- Team membership itself is an app concern: list members, add members where allowed, and handle join-by-access-code flows.

## Share Flow

There are two different share stories you need to keep separate.

### Checked-Out Repo Share Bootstrap

In this checkout, `GET /api/share/:shareId` returns a payload with:

- `websiteId`
- `token`

The app then uses `x-umami-share-token` on later read requests. Server-side permission checks allow read access when that token's `websiteId` matches the target website.

Build share mode as a separate session state rather than pretending it is a normal logged-in account.

### Current Official Share Docs

Current docs also describe managed share-page APIs such as:

- `POST /api/share`
- `GET /api/share/id/:shareId`
- `POST /api/share/id/:shareId`
- `DELETE /api/share/id/:shareId`
- `GET /api/websites/:websiteId/shares`
- `POST /api/websites/:websiteId/shares`

Those managed share routes are not present in this checkout under `src/app/api`.
If you are targeting current Cloud/docs behavior, do not confuse those APIs with the legacy share-token bootstrap route in this repo.

## Good Client Structure

- `AccountSession` for logged-in auth
- `ShareSession` for public/shared read-only access
- `WorkspaceStore` for current team or website selection
- `MembershipStore` for team members, roles, and invitation or join flows

## Boundary Rule

Use this skill for:

- workspace switching
- team CRUD and membership flows
- website lists that span personal and team ownership
- share-mode session handling

Use `umami-selfhosted-auth-admin` for:

- login and verify flows
- self-hosted account bootstrap
- `/users` and `/admin/*` account-management work

Use `umami-website-management` for:

- website settings, reset, transfer, and checkout-specific `shareId` editing

## UX Rules

- Never show write controls in share mode.
- Make team context visible.
- Keep website switching explicit.
- Distinguish "you cannot edit" from "you cannot view."
- Treat website transfer between user and team ownership as a deliberate settings flow.

## Local Anchors

- `src/app/api/share/[shareId]/route.ts`
- `src/app/api/me/route.ts`
- `src/app/api/me/teams/route.ts`
- `src/app/api/me/websites/route.ts`
- `src/app/api/teams/route.ts`
- `src/app/api/teams/[teamId]/route.ts`
- `src/app/api/teams/join/route.ts`
- `src/app/api/teams/[teamId]/users/route.ts`
- `src/app/api/teams/[teamId]/users/[userId]/route.ts`
- `src/app/api/teams/[teamId]/websites/route.ts`
- `src/app/api/websites/[websiteId]/transfer/route.ts`
- `src/lib/constants.ts`
- `src/permissions/website.ts`

## Official Sources

- https://docs.umami.is/docs/api/me
- https://docs.umami.is/docs/api/teams
- https://docs.umami.is/docs/api/share
- https://docs.umami.is/docs/api/websites
