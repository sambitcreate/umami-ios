# Umami Analytics API — Comprehensive Reference (2025)

> A practical, developer-friendly compendium of Umami’s latest API surface (self-hosted & Umami Cloud), including base URLs, auth, key endpoints, request parameters, payload formats for sending stats, realtime, reports, and safe usage patterns. Where the official docs split topics across pages, this file pulls them into one place with examples.

---

## Table of contents

1. [What is Umami & where the API lives](#what-is-umami--where-the-api-lives)
2. [Base URLs & environments](#base-urls--environments)
3. [Authentication](#authentication)

   * [Self-hosted: session token](#selfhosted-session-token)
   * [Umami Cloud: API key header](#umami-cloud-api-key-header)
   * [Using the official TypeScript API client](#using-the-official-typescript-api-client)
4. [Tracker & data ingestion](#tracker--data-ingestion)

   * [Send endpoint (`/api/send`) & payload](#send-endpoint-apisend--payload)
   * [Overriding IP, userAgent, timestamp](#overriding-ip-useragent-timestamp)
   * [Avoiding ad-blockers (`COLLECT_API_ENDPOINT`)](#avoiding-adblockers-collect_api_endpoint)
5. [Core REST endpoints](#core-rest-endpoints)

   * [Websites API](#websites-api)
   * [Website statistics API](#website-statistics-api)
   * [Events API](#events-api)
   * [Sessions API](#sessions-api)
   * [Realtime API](#realtime-api)
   * [Users API](#users-api)
   * [Me API](#me-api)
   * [Teams API](#teams-api)
   * [Reports API](#reports-api)
6. [Metric definitions (how Umami calculates things)](#metric-definitions-how-umami-calculates-things)
7. [Cloud-only notes: API changelog & CORS](#cloudonly-notes-api-changelog--cors)
8. [Examples (cURL, JS/TS, Python)](#examples-curl-jsts-python)
9. [Errors, pagination, and filtering](#errors-pagination-and-filtering)
10. [Security best practices](#security-best-practices)
11. [Versioning & release highlights](#versioning--release-highlights)
12. [Useful links](#useful-links)

---

## What is Umami & where the API lives

Umami is a modern, open-source, privacy-focused web analytics platform. It exposes a first-class REST API so “anything you can do in the app” can be done programmatically. ([Umami][1])

---

## Base URLs & environments

* **Self-hosted (your instance):**
  `https://<your-umami-host>` — all endpoints are served under `/api/...`. ([Umami][2])

* **Umami Cloud (hosted by Umami):**
  **Analytics API base**: `https://api.umami.is/v1` (authenticated via API key).
  **Collector** (for tracker `send`): `https://cloud.umami.is/api/send`. ([Umami][3])

---

## Authentication

### Self-hosted: session token

1. `POST /api/auth/login` with your credentials.
2. Store the returned token.
3. Send `Authorization: Bearer <token>` on subsequent requests. ([Umami][4])

> **Note:** The “login + bearer token” flow is only for **self-hosted**. For Cloud, use an API key. ([Umami][4])

### Umami Cloud: API key header

* Generate an API key in Umami Cloud.
* Call `https://api.umami.is/v1/...` and include header:
  `x-umami-api-key: <YOUR_API_KEY>` ([Umami][3])

> Example of the header name & base path are explicitly documented for Cloud. ([Umami][3])

### Using the official TypeScript API client

* Package: **`@umami/api-client`** (TypeScript).
* Install: `yarn add @umami/api-client`
* Example:

  ```ts
  import { client } from '@umami/api-client';

  // auto-reads UMAMI env or you can configure
  const { ok, data, status, error } = await client.getWebsites();
  ```

  The client maps methods like `getWebsites()`, `getWebsitePageviews(id, data)` to the documented REST endpoints. ([GitHub][5])

---

## Tracker & data ingestion

### Send endpoint (`/api/send`) & payload

To record pageviews or custom events from websites/apps, send a POST to the **collector**:

* **Self-hosted:** `POST https://<your-umami-host>/api/send`
* **Cloud:** `POST https://cloud.umami.is/api/send` ([Umami][6])

The `/api/send` endpoint accepts a JSON payload describing the hit (pageview or event). (See also **payload limits** like event name length.) ([Umami][6])

> **Event name length:** server validation enforces max length (e.g., `"payload.name must be at most 50 characters"`). Keep your event names concise. ([GitHub][7])

### Overriding IP, userAgent, timestamp

As of **v2.17** you can include optional overrides in the `/api/send` payload when sending from non-browser contexts:

* `ip` — source IP address
* `userAgent` — user agent string (must be valid to avoid bot flags)
* `timestamp` — UNIX epoch seconds to back-date the event
  These override values are now honored server-side. ([Umami][8])

### Avoiding ad-blockers (`COLLECT_API_ENDPOINT`)

If your self-hosted scripts are being blocked, you can **rename** the default collector path by setting:

```
COLLECT_API_ENDPOINT=/my-collect-path
```

This changes the ingest endpoint path from `/api/send` to your chosen value, letting you route around blockers. ([Umami][9])

---

## Core REST endpoints

> Paths here are shown for **self-hosted** (e.g., `/api/...`). For **Cloud**, prepend `https://api.umami.is/v1` and include the `x-umami-api-key` header. ([Umami][3])

### Websites API

Operations for managing tracked websites and their metadata.

* `GET /api/websites` — list all tracked websites.
* `POST /api/websites` — create a website. Body includes fields such as:

  * `domain` (string) — full site domain
  * `name` (string) — display name
  * `shareId` (… if you plan to expose a share URL)
* `GET /api/websites/:websiteId` — details for a website.
* Other management endpoints exist under the same resource root. ([Umami][10])

### Website statistics API

Aggregate traffic data for a website within a time window:

* `GET /api/websites/:websiteId/active` — current active visitors.
  Sample response: `{ "visitors": 5 }`
* `GET /api/websites/:websiteId/pageviews` — timeseries of pageviews/sessions.
  **Params:** `startAt` (ms epoch), `endAt` (ms epoch), etc.
* `GET /api/websites/:websiteId/metrics` — aggregate metrics over a range (referrers, pages, etc.).
* `GET /api/websites/:websiteId/stats` — summary stats (visitors, bounces, totaltime, change…).
  **Params** for these endpoints commonly include `startAt`, `endAt`. ([Umami][11])

### Events API

* `GET /api/websites/:websiteId/events` — event details within the time range.
  **Params:** `startAt`, `endAt`, and optional selectors/limits. ([Umami][12])

> **Cloud changelog note:** A series endpoint was added for event metrics:
> `GET /websites/[id]/events/series` (previously `GET .../events`). ([Umami][13])

### Sessions API

* `GET /api/websites/:websiteId/sessions` — session details in a given time range.
  **Params:** `startAt`, `endAt`. ([Umami][14])

### Realtime API

* `GET /api/realtime/:websiteId` — realtime data for a website (active users, pages). ([Umami][15])

### Users API

* `GET /api/users/:userId/teams` — list teams a user belongs to.
  **Query params:** `query` (search text), `page` (default 1), `pageSize` … ([Umami][16])

### Me API

Authenticated “who am I” & quick lookups:

* `GET /api/me` — user/session info from your token
* `GET /api/me/teams` — teams for the current user
* `GET /api/me/websites` — websites for the current user ([Umami][17])

### Teams API

Manage teams & membership:

* `POST /api/teams` — create a team
* `POST /api/teams/join` — accept an invite / join flow
* `GET /api/teams/:teamId` — team details
* `DELETE /api/teams/:teamId` — delete team
  (Additional team endpoints exist; see official page.) ([Umami][18])

### Reports API

Programmatic reports (example endpoint):

* `POST /api/reports/revenue` — revenue-focused report over a date range
  **Body:** `dateRange` with `startDate` (number), `endDate` (number), etc. ([Umami][19])

> **Related doc:** “Insights report” describes fields combining pageview & session metrics that power insight reporting. ([Umami][20])

---

## Metric definitions (how Umami calculates things)

Umami’s docs provide canonical definitions for **event metrics**, **session metrics**, **location metrics**, and **calculated metrics** (e.g., “bounces”, “totaltime”, etc.). Always align your interpretations with these definitions when turning API responses into dashboards. ([Umami][21])

> **Bounce clarification:** Community discussion clarifies that **`bounces` are single-page sessions** (a visitor viewed only one page in an hour), and **`uniques` corresponds to unique visitors / sessions** for the chosen period—useful when reconciling `/stats` vs `/pageviews`. ([GitHub][22])

---

## Cloud-only notes: API changelog & CORS

* **Cloud API base path & key:** `https://api.umami.is/v1` with header `x-umami-api-key`. The Cloud docs also maintain an **API changelog** (e.g., events series endpoint, query additions on `GET /reports/index`). ([Umami][3])
* **CORS:** Some developers report CORS restrictions for direct browser calls to Cloud. In practice, call the Cloud API **from your server/backend** instead of the browser. ([GitHub][23])

---

## Examples (cURL, JS/TS, Python)

> Replace `WEBSITE_ID`, `YOUR_HOST`, and timestamps as needed.

### Cloud — list websites (cURL)

```bash
curl -s https://api.umami.is/v1/websites \
  -H 'accept: application/json' \
  -H 'x-umami-api-key: YOUR_API_KEY'
```

(Cloud base and header name from official docs.) ([Umami][3])

### Self-hosted — login then get stats (cURL)

```bash
# 1) Login to get a token
TOKEN=$(curl -s -X POST https://YOUR_HOST/api/auth/login \
  -H 'content-type: application/json' \
  -d '{"username":"admin","password":"secret"}' \
  | jq -r '.token')

# 2) Pull stats time range
START=$(date -v-7d +%s)000   # 7 days ago, ms epoch (macOS date)
END=$(date +%s)000           # now, ms epoch

curl -s "https://YOUR_HOST/api/websites/WEBSITE_ID/stats?startAt=$START&endAt=$END" \
  -H "authorization: Bearer $TOKEN"
```

(Self-hosted login & bearer usage.) ([Umami][4])

### Send a pageview/event (Cloud collector)

```bash
curl -s -X POST https://cloud.umami.is/api/send \
  -H 'content-type: application/json' \
  -d '{
    "type": "event",
    "payload": {
      "website": "WEBSITE_ID",
      "name": "signup_submit",
      "url": "https://example.com/signup",
      "host": "example.com"
    }
  }'
```

> Keep event names short; server validates name length. For non-browser contexts you may add `ip`, `userAgent`, `timestamp` to the payload to override inference. ([Umami][6])

### Node/TS with the official client

```ts
import { client } from '@umami/api-client';

// Example: fetch websites (Cloud or self-hosted depending on your env)
const res = await client.getWebsites();
if (!res.ok) throw new Error(res.error || `HTTP ${res.status}`);
console.log(res.data);

// Example: pageviews timeseries
const startAt = Date.now() - 7 * 24 * 60 * 60 * 1000;
const endAt = Date.now();
const pv = await client.getWebsitePageviews('WEBSITE_ID', { startAt, endAt });
```

(Methods map to the REST reference.) ([GitHub][5])

### Python (community client)

```python
# pip install umami-analytics
from umami_analytics import Umami

u = Umami(
    base_url="https://api.umami.is/v1",
    api_key="YOUR_API_KEY",
)

sites = u.list_websites()
stats = u.get_website_stats(website_id="WEBSITE_ID", start_at=START, end_at=END)
print(stats)
```

(Python client capabilities include add event, add page view, list websites, get stats, active users, etc.) ([PyPI][24])

---

## Errors, pagination, and filtering

* **401 Unauthorized:** bad/absent token (self-hosted) or API key (Cloud).
* **405 Method Not Allowed:** calling an endpoint with the wrong method (seen historically on `/metrics`). Verify verb & path. ([GitHub][25])
* **CORS:** Cloud API often not callable from browsers—use a backend. ([GitHub][23])
* **Common query params** (varies by endpoint): `startAt`/`endAt` (ms epoch), and for list endpoints `query`, `page`, `pageSize`. Verify per endpoint page. ([Umami][12])

---

## Security best practices

* **Do not expose** the Cloud API key in front-end code; call from a server/app you control. (CORS issues also reinforce this.) ([GitHub][23])
* Rotate keys regularly; store in secrets managers.
* For self-hosted, protect admin credentials; send tokens over HTTPS only.

---

## Versioning & release highlights

* **Cloud API base path:** `https://api.umami.is/v1` (use header `x-umami-api-key`). ([Umami][3])
* **API changelog highlights** (Cloud):

  * Added `GET /websites/[id]/events/series` for event metrics.
  * `GET /reports/index` gained `websiteId` & `teamId` query params. ([Umami][13])
* **Tracker improvements** (v2.17): payload overrides for `/api/send` (`ip`, `userAgent`, `timestamp`). ([Umami][8])
* **Realtime & stats pages** updated over recent minor versions; see blog “v2.16.0” (new metrics sections) and later. ([Umami][26])

---

## Useful links

* API landing page (reference index). ([Umami][2])
* Authentication (self-hosted) & API client docs. ([Umami][4])
* Cloud: API key, login, usage, changelog. ([Umami][3])
* Websites / Stats / Events / Sessions / Realtime / Users / Me / Teams / Reports. ([Umami][10])
* Sending stats (collector). ([Umami][6])
* Metric definitions & insights report. ([Umami][21])
* Source code & release notes. ([GitHub][27])

---

### Appendix A — Minimal field cheat-sheet (by area)

> Always consult the endpoint’s reference before relying on a field at scale; Umami evolves and Cloud’s changelog may rename/expand some fields.

* **Common query window:** `startAt` (ms), `endAt` (ms) on stats/time-series endpoints. ([Umami][12])
* **Website create:** `domain`, `name`, optional sharing fields such as `shareId`. ([Umami][10])
* **Realtime:** `/active` or `/realtime/:websiteId` for current visitors. ([Umami][11])
* **Events:** `GET .../events` (and Cloud `.../events/series`) for event metrics. ([Umami][12])
* **Collector `/api/send`:** payload includes `type` (“event” or pageview), `payload.website`, `payload.name` (≤ max length), `url`, `host`; optional overrides `ip`, `userAgent`, `timestamp`. ([Umami][6])
* **Cloud header:** `x-umami-api-key`, base `https://api.umami.is/v1`. ([Umami][3])

---

### Appendix B — Troubleshooting tips

* **405 on `/metrics`:** verify method (use `GET`) and the exact path/version you’re calling. ([GitHub][28])
* **Unauthorized (Cloud):** ensure `x-umami-api-key` header is sent and you’re using the `/v1` base. ([GitHub][25])
* **Browser calls failing:** expected for Cloud; call via server to avoid CORS issues. ([GitHub][23])
* **Events not recording:** check event name length & payload shape; the server returns descriptive validation errors if you call the collector directly. ([GitHub][7])

---

If you want, I can tailor this into a **Notion-ready** page or add **endpoint-by-endpoint cURL templates** for your specific sites (with your IDs and time windows).

[1]: https://umami.is/docs?utm_source=chatgpt.com "Overview – Docs - Umami"
[2]: https://umami.is/docs/api?utm_source=chatgpt.com "API – Docs"
[3]: https://umami.is/docs/cloud/api-key?utm_source=chatgpt.com "API Key – Docs"
[4]: https://umami.is/docs/api/authentication?utm_source=chatgpt.com "Authentication – Docs"
[5]: https://github.com/umami-software/api-client?utm_source=chatgpt.com "API client for Umami Analytics"
[6]: https://umami.is/docs/api/sending-stats?utm_source=chatgpt.com "Sending stats – Docs"
[7]: https://github.com/umami-software/umami/issues/2986?utm_source=chatgpt.com "For malformed `/send` requests, the reason for the rejection ..."
[8]: https://umami.is/blog/umami-v2.17.0?utm_source=chatgpt.com "Umami v2.17.0 – Blog"
[9]: https://umami.is/docs/environment-variables?utm_source=chatgpt.com "Environment variables – Docs"
[10]: https://umami.is/docs/api/websites-api?utm_source=chatgpt.com "Websites – Docs"
[11]: https://umami.is/docs/api/website-stats-api?utm_source=chatgpt.com "Website statistics – Docs"
[12]: https://umami.is/docs/api/events-api?utm_source=chatgpt.com "Events – Docs"
[13]: https://umami.is/docs/cloud/api-changelog?utm_source=chatgpt.com "API changelog – Docs"
[14]: https://umami.is/docs/api/sessions-api?utm_source=chatgpt.com "Sessions – Docs"
[15]: https://umami.is/docs/api/realtime-api?utm_source=chatgpt.com "Realtime – Docs"
[16]: https://umami.is/docs/api/users-api?utm_source=chatgpt.com "Users – Docs"
[17]: https://umami.is/docs/api/me-api?utm_source=chatgpt.com "Me – Docs"
[18]: https://umami.is/docs/api/teams-api?utm_source=chatgpt.com "Teams – Docs"
[19]: https://umami.is/docs/api/reports-api?utm_source=chatgpt.com "Reports – Docs"
[20]: https://umami.is/docs/reports/report-insights?utm_source=chatgpt.com "Insights report – Docs"
[21]: https://umami.is/docs/metric-definitions?utm_source=chatgpt.com "Metric definitions – Docs"
[22]: https://github.com/umami-software/umami/discussions/2544?utm_source=chatgpt.com "Question about stats #2544"
[23]: https://github.com/umami-software/umami/issues/2881?utm_source=chatgpt.com "CORS Policy Issue with Umami Cloud API Access #2881"
[24]: https://pypi.org/project/umami-analytics/?utm_source=chatgpt.com "umami-analytics"
[25]: https://github.com/umami-software/umami/discussions/3014?utm_source=chatgpt.com "All my API calls are giving Unauthorized #3014"
[26]: https://umami.is/blog/umami-v2.16.0?utm_source=chatgpt.com "Umami v2.16.0 – Blog"
[27]: https://github.com/umami-software/umami?utm_source=chatgpt.com "Umami is a modern, privacy-focused alternative to Google ..."
[28]: https://github.com/umami-software/umami/issues/2134?utm_source=chatgpt.com "GET /api/websites/{websiteUuid}/metrics Returns 405 ..."
