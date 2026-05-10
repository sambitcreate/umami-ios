---
name: umami-selfhosted-auth-admin
description: Work with self-hosted Umami authentication and admin-only APIs. Use when implementing login, token verification, logout, instance config probing, password changes, SSO-aware flows, user management, and self-hosted-only admin behavior in a native app.
---

# Umami Self-Hosted Auth Admin

Use this skill only for self-hosted instances. Cloud uses API keys instead.

## Core Auth Flow

1. `POST /api/auth/login`
2. store returned bearer token securely
3. attach `Authorization: Bearer <token>` to authenticated requests
4. call `POST /api/auth/verify` when you need to rehydrate a session

## Secure Storage

- Store bearer tokens in Keychain.
- Keep instance URL and username separately from the token.
- Treat logout as both local token removal and remote session cleanup if your flow uses the logout endpoint.

For native apps, store self-hosted bearer tokens in Keychain and keep them distinct from any share-token or Cloud-key session state.

## Session Bootstrap

Treat self-hosted account bootstrap as a sequence, not a single token exchange:

1. `POST /api/auth/login`
2. `GET /api/config`
3. `GET /api/me`
4. `GET /api/me/teams`
5. `GET /api/me/websites?includeTeams=true` when the app needs a combined picker

`/api/me` is the lightweight "who am I and what auth mode do I have?" call.
Use it to restore a bearer-token session before you load heavier workspace data.

## Config Probing

`GET /api/config` is useful before building the app session. The checked-out repo exposes flags such as:

- `cloudMode`
- `privateMode`
- `trackerScriptName`
- `linksUrl`
- `pixelsUrl`

Probe config early so the app can adapt to instance capabilities.

## SSO Caveat

The checked-out repo includes `POST /api/auth/sso`, but the official authentication docs do not document it as a general client login flow.

- Treat it as deployment-specific behavior, not a portable Umami API contract.
- Do not build an iOS SSO flow around it unless you have confirmed the target instance setup.
- The local route only returns a token when auth already exists and Redis-backed auth is enabled.

## Admin-Only Surfaces

These are self-hosted territory:

- `/me/password`
- `/users`
- `/users/*`
- `/admin/users`
- `/admin/websites`
- `/admin/teams`
- password-change flows for authenticated accounts

Do not surface them in Cloud mode.

## Concrete User and Admin APIs

When the task is truly account or admin work, model these directly instead of hand-waving "admin flows":

- `/users` for user creation
- `/users/:userId` for view, role changes, username changes, password reset, and deletion
- `/users/:userId/teams` and `/users/:userId/websites` for account-management screens
- `/admin/users`, `/admin/websites`, and `/admin/teams` for global instance administration

If the task is about team membership inside a normal workspace UI, prefer `umami-workspaces-and-sharing` instead.
Use this skill when the problem is account session setup, self-hosted capability detection, or self-hosted-only user/admin management.

## Product Guidance

- Support custom instance URLs cleanly.
- Expect instance-specific version skew.
- Fail helpfully when an endpoint exists in docs but not on the connected server.
- Keep SSO logins and password logins as separate flows if you add both.
- Be explicit that `/api/auth/logout` is lightweight server cleanup and may be effectively local-only when Redis is not backing sessions.
- Namespace cached auth by normalized instance URL so two self-hosted servers cannot overwrite each other in Keychain or app storage.
- Keep `/api/config` results alongside the account session so Cloud-like flags such as `privateMode`, `trackerScriptName`, `linksUrl`, and `pixelsUrl` are available to the UI without a second bootstrap path.

## Local Anchors

- `src/app/api/auth/login/route.ts`
- `src/app/api/auth/logout/route.ts`
- `src/app/api/auth/verify/route.ts`
- `src/app/api/auth/sso/route.ts`
- `src/app/api/config/route.ts`
- `src/app/api/me/route.ts`
- `src/app/api/me/teams/route.ts`
- `src/app/api/me/websites/route.ts`
- `src/app/api/me/password/route.ts`
- `src/app/api/users/route.ts`
- `src/app/api/users/[userId]/route.ts`
- `src/app/api/users/[userId]/teams/route.ts`
- `src/app/api/users/[userId]/websites/route.ts`
- `src/app/api/admin/users/route.ts`
- `src/app/api/admin/websites/route.ts`
- `src/app/api/admin/teams/route.ts`
- `src/lib/auth.ts`

## Official Sources

- https://docs.umami.is/docs/api/authentication
- https://docs.umami.is/docs/api/users
- https://docs.umami.is/docs/api/admin
- https://docs.umami.is/docs/api/me
