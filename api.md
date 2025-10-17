# Umami API Reference

This document provides a detailed reference for the Umami API endpoints.

## Authentication

Authentication is required for most endpoints. The API uses a token-based authentication system. Include your API token in the `Authorization` header of your requests as a Bearer token.

```
Authorization: Bearer <YOUR_TOKEN>
```

## API Routes

### Admin

*   **GET /api/admin/users**
    *   Description: Get a list of all users.
    *   Query Parameters: `page`, `pageSize`, `search`
*   **GET /api/admin/websites**
    *   Description: Get a list of all websites.
    *   Query Parameters: `page`, `pageSize`, `search`, `userId`, `includeOwnedTeams`, `includeAllTeams`

### Auth

*   **POST /api/auth/login**
    *   Description: Log in to your Umami account.
    *   Request Body: `username`, `password`
*   **POST /api/auth/logout**
    *   Description: Log out of your Umami account.
*   **POST /api/auth/sso**
    *   Description: Single Sign-On.
*   **GET /api/auth/verify**
    *   Description: Verify your authentication token.

### Batch

*   **POST /api/batch**
    *   Description: Send a batch of events to Umami.
    *   Request Body: An array of event objects.

### Heartbeat

*   **GET /api/heartbeat**
    *   Description: Check if the Umami API is running.

### Me

*   **GET /api/me**
    *   Description: Get your user information.
*   **POST /api/me/password**
    *   Description: Change your password.
    *   Request Body: `currentPassword`, `newPassword`
*   **GET /api/me/teams**
    *   Description: Get a list of teams you are a member of.
    *   Query Parameters: `page`, `pageSize`
*   **GET /api/me/websites**
    *   Description: Get a list of websites you have access to.
    *   Query Parameters: `page`, `pageSize`

### Realtime

*   **GET /api/realtime/{websiteId}**
    *   Description: Get realtime data for a website.

### Reports

*   **GET /api/reports**
    *   Description: Get a list of all reports.
    *   Query Parameters: `page`, `pageSize`, `search`, `websiteId`, `teamId`
*   **POST /api/reports**
    *   Description: Create a new report.
    *   Request Body: `websiteId`, `name`, `type`, `description`, `parameters`
*   **GET /api/reports/{reportId}**
    *   Description: Get a specific report.
*   **POST /api/reports/{reportId}**
    *   Description: Update a specific report.
    *   Request Body: `name`, `type`, `description`, `parameters`
*   **DELETE /api/reports/{reportId}**
    *   Description: Delete a specific report.
*   **POST /api/reports/funnel**
    *   Description: Get funnel data for a report.
    *   Request Body: `websiteId`, `dateRange`, `window`, `steps`
*   **POST /api/reports/goals**
    *   Description: Get goals data for a report.
    *   Request Body: `websiteId`, `dateRange`, `goals`
*   **POST /api/reports/insights**
    *   Description: Get insights data for a report.
    *   Request Body: `websiteId`, `dateRange`, `fields`, `filters`
*   **POST /api/reports/journey**
    *   Description: Get journey data for a report.
    *   Request Body: `websiteId`, `dateRange`, `steps`, `startStep`, `endStep`
*   **POST /api/reports/retention**
    *   Description: Get retention data for a report.
    *   Request Body: `websiteId`, `dateRange`, `timezone`
*   **GET /api/reports/revenue**
    *   Description: Get revenue values for a report.
    *   Query Parameters: `websiteId`, `startDate`, `endDate`
*   **POST /api/reports/revenue**
    *   Description: Get revenue data for a report.
    *   Request Body: `websiteId`, `dateRange`, `timezone`, `currency`
*   **POST /api/reports/utm**
    *   Description: Get UTM data for a report.
    *   Request Body: `websiteId`, `dateRange`, `timezone`

### Scripts

*   **GET /api/scripts/telemetry**
    *   Description: Get the Umami telemetry script.

### Send

*   **POST /api/send**
    *   Description: Send an event to Umami.
    *   Request Body: `type`, `payload`

### Share

*   **GET /api/share/{shareId}**
    *   Description: Get a shared website.

### Teams

*   **POST /api/teams**
    *   Description: Create a new team.
    *   Request Body: `name`
*   **POST /api/teams/join**
    *   Description: Join a team.
    *   Request Body: `accessCode`
*   **GET /api/teams/{teamId}**
    *   Description: Get a specific team.
*   **POST /api/teams/{teamId}**
    *   Description: Update a specific team.
    *   Request Body: `name`
*   **DELETE /api/teams/{teamId}**
    *   Description: Delete a specific team.
*   **GET /api/teams/{teamId}/users**
    *   Description: Get a list of users in a team.
    *   Query Parameters: `page`, `pageSize`
*   **POST /api/teams/{teamId}/users**
    *   Description: Add a user to a team.
    *   Request Body: `userId`, `role`
*   **GET /api/teams/{teamId}/users/{userId}**
    *   Description: Get a specific user in a team.
*   **POST /api/teams/{teamId}/users/{userId}**
    *   Description: Update a user's role in a team.
    *   Request Body: `role`
*   **DELETE /api/teams/{teamId}/users/{userId}**
    *   Description: Remove a user from a team.
*   **GET /api/teams/{teamId}/websites**
    *   Description: Get a list of websites in a team.
    *   Query Parameters: `page`, `pageSize`

### Users

*   **POST /api/users**
    *   Description: Create a new user.
    *   Request Body: `id`, `username`, `password`, `role`
*   **GET /api/users/{userId}**
    *   Description: Get a specific user.
*   **POST /api/users/{userId}**
    *   Description: Update a specific user.
    *   Request Body: `username`, `role`
*   **DELETE /api/users/{userId}**
    *   Description: Delete a specific user.
*   **GET /api/users/{userId}/teams**
    *   Description: Get a list of teams a user is a member of.
    *   Query Parameters: `page`, `pageSize`
*   **GET /api/users/{userId}/usage**
    *   Description: Get a user's usage statistics.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/users/{userId}/websites**
    *   Description: Get a list of websites a user has access to.
    *   Query Parameters: `page`, `pageSize`

### Version

*   **GET /api/version**
    *   Description: Get the Umami version.

### Websites

*   **GET /api/websites**
    *   Description: Get a list of all websites.
    *   Query Parameters: `page`, `pageSize`
*   **POST /api/websites**
    *   Description: Create a new website.
    *   Request Body: `name`, `domain`, `shareId`, `teamId`
*   **GET /api/websites/{websiteId}**
    *   Description: Get a specific website.
*   **POST /api/websites/{websiteId}**
    *   Description: Update a specific website.
    *   Request Body: `name`, `domain`, `shareId`
*   **DELETE /api/websites/{websiteId}**
    *   Description: Delete a specific website.
*   **GET /api/websites/{websiteId}/active**
    *   Description: Get the number of active visitors on a website.
*   **GET /api/websites/{websiteId}/daterange**
    *   Description: Get the date range of a website's data.
*   **GET /api/websites/{websiteId}/event-data/events**
    *   Description: Get a list of events for a website.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/event-data/fields**
    *   Description: Get a list of event data fields for a website.
    *   Query Parameters: `eventName`, `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/event-data/properties**
    *   Description: Get a list of event data properties for a website.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/event-data/stats**
    *   Description: Get event data statistics for a website.
    *   Query Parameters: `startAt`, `endAt`, `eventName`, `...filters`
*   **GET /api/websites/{websiteId}/event-data/values**
    *   Description: Get event data values for a website.
    *   Query Parameters: `eventName`, `property`, `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/events**
    *   Description: Get a list of events for a website.
    *   Query Parameters: `startAt`, `endAt`, `unit`, `timezone`
*   **GET /api/websites/{websiteId}/events/series**
    *   Description: Get event series data for a website.
    *   Query Parameters: `startAt`, `endAt`, `unit`, `timezone`, `url`, `eventName`
*   **GET /api/websites/{websiteId}/metrics**
    *   Description: Get pageview or session metrics for a website.
    *   Query Parameters: `type`, `startAt`, `endAt`, `...filters`
*   **GET /api/websites/{websiteId}/pageviews**
    *   Description: Get pageview data for a website.
    *   Query Parameters: `startAt`, `endAt`, `unit`, `timezone`
*   **GET /api/websites/{websiteId}/reports**
    *   Description: Get a list of reports for a website.
    *   Query Parameters: `page`, `pageSize`
*   **POST /api/websites/{websiteId}/reset**
    *   Description: Reset a website's data.
*   **GET /api/websites/{websiteId}/session-data/properties**
    *   Description: Get a list of session data properties for a website.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/session-data/values**
    *   Description: Get session data values for a website.
    *   Query Parameters: `property`, `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/sessions**
    *   Description: Get a list of sessions for a website.
    *   Query Parameters: `startAt`, `endAt`, `page`, `pageSize`, `...filters`
*   **GET /api/websites/{websiteId}/sessions/stats**
    *   Description: Get session statistics for a website.
    *   Query Parameters: `startAt`, `endAt`, `...filters`
*   **GET /api/websites/{websiteId}/sessions/weekly**
    *   Description: Get weekly session data for a website.
    *   Query Parameters: `startAt`, `endAt`, `timezone`
*   **GET /api/websites/{websiteId}/sessions/{sessionId}**
    *   Description: Get a specific session.
*   **GET /api/websites/{websiteId}/sessions/{sessionId}/activity**
    *   Description: Get a session's activity.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/sessions/{sessionId}/properties**
    *   Description: Get a session's properties.
    *   Query Parameters: `startAt`, `endAt`
*   **GET /api/websites/{websiteId}/stats**
    *   Description: Get website statistics.
    *   Query Parameters: `startAt`, `endAt`, `...filters`
*   **POST /api/websites/{websiteId}/transfer**
    *   Description: Transfer a website to another user.
    *   Request Body: `userId`
*   **GET /api/websites/{websiteId}/values**
    *   Description: Get pageview values for a website.
    *   Query Parameters: `type`, `startAt`, `endAt`, `...filters`

## Swift Code Example

Here is an example of how to fetch the Umami version using Swift:

```swift
import Foundation

// Define the structure to match the JSON response
struct UmamiVersion: Codable {
    let version: String
}

// Your Umami API base URL
let baseURL = "https://your-umami-instance.com/api"

func fetchUmamiVersion() {
    guard let url = URL(string: "\(baseURL)/version") else {
        print("Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle network errors
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            return
        }

        // Check for a successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Error: Invalid response or status code")
            return
        }

        // Ensure data is not nil
        guard let data = data else {
            print("Error: No data received")
            return
        }

        // Decode the JSON data
        do {
            let umamiVersion = try JSONDecoder().decode(UmamiVersion.self, from: data)
            print("Successfully fetched Umami version: \(umamiVersion.version)")
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }

    task.resume()
}

// Call the function to fetch the version
fetchUmamiVersion()
```
================================================
FILE: src/app/api/admin/users/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { json, unauthorized } from '@/lib/response';
import { pagingParams } from '@/lib/schema';
import { canViewUsers } from '@/lib/auth';
import { getUsers } from '@/queries/prisma/user';

export async function GET(request: Request) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canViewUsers(auth))) {
    return unauthorized();
  }

  const users = await getUsers(
    {
      include: {
        _count: {
          select: {
            websiteUser: {
              where: { deletedAt: null },
            },
          },
        },
      },
    },
    query,
  );

  return json(users);
}



================================================
FILE: src/app/api/admin/websites/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { json, unauthorized } from '@/lib/response';
import { pagingParams } from '@/lib/schema';
import { canViewAllWebsites } from '@/lib/auth';
import { getWebsites } from '@/queries/prisma/website';
import { ROLES } from '@/lib/constants';

export async function GET(request: Request) {
  const schema = z.object({
    userId: z.string().uuid(),
    includeOwnedTeams: z.string().optional(),
    includeAllTeams: z.string().optional(),
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canViewAllWebsites(auth))) {
    return unauthorized();
  }

  const { userId, includeOwnedTeams, includeAllTeams } = query;

  const websites = await getWebsites(
    {
      where: {
        OR: [
          ...(userId && [{ userId }]),
          ...(userId && includeOwnedTeams
            ? [
                {
                  team: {
                    deletedAt: null,
                    teamUser: {
                      some: {
                        role: ROLES.teamOwner,
                        userId,
                      },
                    },
                  },
                },
              ]
            : []),
          ...(userId && includeAllTeams
            ? [
                {
                  team: {
                    deletedAt: null,
                    teamUser: {
                      some: {
                        userId,
                      },
                    },
                  },
                },
              ]
            : []),
        ],
      },
      include: {
        user: {
          select: {
            username: true,
            id: true,
          },
        },
        team: {
          where: {
            deletedAt: null,
          },
          include: {
            teamUser: {
              where: {
                role: ROLES.teamOwner,
              },
            },
          },
        },
      },
    },
    query,
  );

  return json(websites);
}



================================================
FILE: src/app/api/auth/login/route.ts
================================================
import { z } from 'zod';
import { checkPassword } from '@/lib/auth';
import { createSecureToken } from '@/lib/jwt';
import redis from '@/lib/redis';
import { getUserByUsername } from '@/queries';
import { json, unauthorized } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { saveAuth } from '@/lib/auth';
import { secret } from '@/lib/crypto';
import { ROLES } from '@/lib/constants';

export async function POST(request: Request) {
  const schema = z.object({
    username: z.string(),
    password: z.string(),
  });

  const { body, error } = await parseRequest(request, schema, { skipAuth: true });

  if (error) {
    return error();
  }

  const { username, password } = body;

  const user = await getUserByUsername(username, { includePassword: true });

  if (!user || !checkPassword(password, user.password)) {
    return unauthorized('message.incorrect-username-password');
  }

  const { id, role, createdAt } = user;

  let token: string;

  if (redis.enabled) {
    token = await saveAuth({ userId: id, role });
  } else {
    token = createSecureToken({ userId: user.id, role }, secret());
  }

  return json({
    token,
    user: { id, username, role, createdAt, isAdmin: role === ROLES.admin },
  });
}



================================================
FILE: src/app/api/auth/logout/route.ts
================================================
import redis from '@/lib/redis';
import { ok } from '@/lib/response';

export async function POST(request: Request) {
  if (redis.enabled) {
    const token = request.headers.get('authorization')?.split(' ')?.[1];

    await redis.client.del(token);
  }

  return ok();
}



================================================
FILE: src/app/api/auth/sso/route.ts
================================================
import redis from '@/lib/redis';
import { json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { saveAuth } from '@/lib/auth';

export async function POST(request: Request) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  if (redis.enabled) {
    const token = await saveAuth({ userId: auth.user.id }, 86400);

    return json({ user: auth.user, token });
  }
}



================================================
FILE: src/app/api/auth/verify/route.ts
================================================
import { parseRequest } from '@/lib/request';
import { json } from '@/lib/response';

export async function POST(request: Request) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  return json(auth.user);
}



================================================
FILE: src/app/api/batch/route.ts
================================================
import { z } from 'zod';
import * as send from '@/app/api/send/route';
import { parseRequest } from '@/lib/request';
import { json, serverError } from '@/lib/response';

const schema = z.array(z.object({}).passthrough());

export async function POST(request: Request) {
  try {
    const { body, error } = await parseRequest(request, schema, { skipAuth: true });

    if (error) {
      return error();
    }

    const errors = [];

    let index = 0;
    for (const data of body) {
      const newRequest = new Request(request, { body: JSON.stringify(data) });
      const response = await send.POST(newRequest);

      if (!response.ok) {
        errors.push({ index, response: await response.json() });
      }

      index++;
    }

    return json({
      size: body.length,
      processed: body.length - errors.length,
      errors: errors.length,
      details: errors,
    });
  } catch (e) {
    return serverError(e);
  }
}



================================================
FILE: src/app/api/heartbeat/route.ts
================================================
export async function GET() {
  return Response.json({ ok: true });
}



================================================
FILE: src/app/api/me/route.ts
================================================
import { parseRequest } from '@/lib/request';
import { json } from '@/lib/response';

export async function GET(request: Request) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  return json(auth);
}



================================================
FILE: src/app/api/me/password/route.ts
================================================
import { z } from 'zod';
import { checkPassword, hashPassword } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { json, badRequest } from '@/lib/response';
import { getUser, updateUser } from '@/queries/prisma/user';

export async function POST(request: Request) {
  const schema = z.object({
    currentPassword: z.string(),
    newPassword: z.string().min(8),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const userId = auth.user.id;
  const { currentPassword, newPassword } = body;

  const user = await getUser(userId, { includePassword: true });

  if (!checkPassword(currentPassword, user.password)) {
    return badRequest('Current password is incorrect');
  }

  const password = hashPassword(newPassword);

  const updated = await updateUser(userId, { password });

  return json(updated);
}



================================================
FILE: src/app/api/me/teams/route.ts
================================================
import { z } from 'zod';
import { pagingParams } from '@/lib/schema';
import { getUserTeams } from '@/queries';
import { json } from '@/lib/response';
import { parseRequest } from '@/lib/request';

export async function GET(request: Request) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const teams = await getUserTeams(auth.user.id, query);

  return json(teams);
}



================================================
FILE: src/app/api/me/websites/route.ts
================================================
import { z } from 'zod';
import { pagingParams } from '@/lib/schema';
import { getUserWebsites } from '@/queries';
import { json } from '@/lib/response';
import { parseRequest } from '@/lib/request';

export async function GET(request: Request) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const websites = await getUserWebsites(auth.user.id, query);

  return json(websites);
}



================================================
FILE: src/app/api/realtime/[websiteId]/route.ts
================================================
import { json, unauthorized } from '@/lib/response';
import { getRealtimeData } from '@/queries';
import { canViewWebsite } from '@/lib/auth';
import { startOfMinute, subMinutes } from 'date-fns';
import { REALTIME_RANGE } from '@/lib/constants';
import { parseRequest } from '@/lib/request';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, query, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { timezone } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = subMinutes(startOfMinute(new Date()), REALTIME_RANGE);

  const data = await getRealtimeData(websiteId, { startDate, timezone });

  return json(data);
}



================================================
FILE: src/app/api/reports/route.ts
================================================
import { z } from 'zod';
import { uuid } from '@/lib/crypto';
import { pagingParams, reportTypeParam } from '@/lib/schema';
import { parseRequest } from '@/lib/request';
import { canViewTeam, canViewWebsite, canUpdateWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { getReports, createReport } from '@/queries';

export async function GET(request: Request) {
  const schema = z.object({
    websiteId: z.string().uuid().optional(),
    teamId: z.string().uuid().optional(),
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { page, search, pageSize, websiteId, teamId } = query;
  const userId = auth.user.id;
  const filters = {
    page,
    pageSize,
    search,
  };

  if (
    (websiteId && !(await canViewWebsite(auth, websiteId))) ||
    (teamId && !(await canViewTeam(auth, teamId)))
  ) {
    return unauthorized();
  }

  const data = await getReports(
    {
      where: {
        OR: [
          ...(websiteId ? [{ websiteId }] : []),
          ...(teamId
            ? [
                {
                  website: {
                    deletedAt: null,
                    teamId,
                  },
                },
              ]
            : []),
          ...(userId && !websiteId && !teamId
            ? [
                {
                  website: {
                    deletedAt: null,
                    userId,
                  },
                },
              ]
            : []),
        ],
      },
      include: {
        website: {
          select: {
            domain: true,
          },
        },
      },
    },
    filters,
  );

  return json(data);
}

export async function POST(request: Request) {
  const schema = z.object({
    websiteId: z.string().uuid(),
    name: z.string().max(200),
    type: reportTypeParam,
    description: z.string().max(500),
    parameters: z.object({}).passthrough(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId, type, name, description, parameters } = body;

  if (!(await canUpdateWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const result = await createReport({
    id: uuid(),
    userId: auth.user.id,
    websiteId,
    type,
    name,
    description,
    parameters: parameters,
  } as any);

  return json(result);
}



================================================
FILE: src/app/api/reports/[reportId]/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { deleteReport, getReport, updateReport } from '@/queries';
import { canDeleteReport, canUpdateReport, canViewReport } from '@/lib/auth';
import { unauthorized, json, notFound, ok } from '@/lib/response';
import { reportTypeParam } from '@/lib/schema';

export async function GET(request: Request, { params }: { params: Promise<{ reportId: string }> }) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { reportId } = await params;

  const report = await getReport(reportId);

  if (!(await canViewReport(auth, report))) {
    return unauthorized();
  }

  return json(report);
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ reportId: string }> },
) {
  const schema = z.object({
    websiteId: z.string().uuid(),
    type: reportTypeParam,
    name: z.string().max(200),
    description: z.string().max(500),
    parameters: z.object({}).passthrough(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { reportId } = await params;
  const { websiteId, type, name, description, parameters } = body;

  const report = await getReport(reportId);

  if (!report) {
    return notFound();
  }

  if (!(await canUpdateReport(auth, report))) {
    return unauthorized();
  }

  const result = await updateReport(reportId, {
    websiteId,
    userId: auth.user.id,
    type,
    name,
    description,
    parameters: parameters,
  } as any);

  return json(result);
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ reportId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { reportId } = await params;
  const report = await getReport(reportId);

  if (!(await canDeleteReport(auth, report))) {
    return unauthorized();
  }

  await deleteReport(reportId);

  return ok();
}



================================================
FILE: src/app/api/reports/attribution/route.ts
================================================
import { canViewWebsite } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { json, unauthorized } from '@/lib/response';
import { reportParms } from '@/lib/schema';
import { getAttribution } from '@/queries/sql/reports/getAttribution';
import { z } from 'zod';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    model: z.string().regex(/firstClick|lastClick/i),
    steps: z
      .array(
        z.object({
          type: z.string(),
          value: z.string(),
        }),
      )
      .min(1),
    currency: z.string().optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    model,
    steps,
    currency,
    dateRange: { startDate, endDate },
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getAttribution(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    model: model,
    steps,
    currency,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/funnel/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getFunnel } from '@/queries';
import { reportParms } from '@/lib/schema';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    window: z.coerce.number().positive(),
    steps: z
      .array(
        z.object({
          type: z.string(),
          value: z.string(),
        }),
      )
      .min(2),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    steps,
    window,
    dateRange: { startDate, endDate },
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getFunnel(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    steps,
    windowMinutes: +window,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/goals/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getGoals } from '@/queries/sql/reports/getGoals';
import { reportParms } from '@/lib/schema';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    goals: z
      .array(
        z
          .object({
            type: z.string().regex(/url|event|event-data/),
            value: z.string(),
            goal: z.coerce.number(),
            operator: z
              .string()
              .regex(/count|sum|average/)
              .optional(),
            property: z.string().optional(),
          })
          .refine(data => {
            if (data['type'] === 'event-data') {
              return data['operator'] && data['property'];
            }
            return true;
          }),
      )
      .min(1),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    dateRange: { startDate, endDate },
    goals,
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getGoals(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    goals,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/insights/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getInsights } from '@/queries';
import { reportParms } from '@/lib/schema';

function convertFilters(filters: any[]) {
  return filters.reduce((obj, filter) => {
    obj[filter.name] = filter;

    return obj;
  }, {});
}

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    fields: z
      .array(
        z.object({
          name: z.string(),
          type: z.string(),
          label: z.string(),
        }),
      )
      .min(1),
    filters: z.array(
      z.object({
        name: z.string(),
        type: z.string(),
        operator: z.string(),
        value: z.string(),
      }),
    ),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    dateRange: { startDate, endDate },
    fields,
    filters,
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getInsights(websiteId, fields, {
    ...convertFilters(filters),
    startDate: new Date(startDate),
    endDate: new Date(endDate),
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/journey/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getJourney } from '@/queries';
import { reportParms } from '@/lib/schema';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    steps: z.coerce.number().min(3).max(7),
    startStep: z.string().optional(),
    endStep: z.string().optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    dateRange: { startDate, endDate },
    steps,
    startStep,
    endStep,
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getJourney(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    steps,
    startStep,
    endStep,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/retention/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getRetention } from '@/queries';
import { reportParms, timezoneParam } from '@/lib/schema';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
    timezone: timezoneParam,
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    dateRange: { startDate, endDate },
    timezone,
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getRetention(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    timezone,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/revenue/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { reportParms, timezoneParam } from '@/lib/schema';
import { getRevenue } from '@/queries/sql/reports/getRevenue';
import { getRevenueValues } from '@/queries/sql/reports/getRevenueValues';

export async function GET(request: Request) {
  const { auth, query, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId, startDate, endDate } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getRevenueValues(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
  });

  return json(data);
}

export async function POST(request: Request) {
  const schema = z.object({
    currency: z.string(),
    ...reportParms,
    timezone: timezoneParam,
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    currency,
    timezone,
    dateRange: { startDate, endDate, unit },
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getRevenue(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    unit,
    timezone,
    currency,
  });

  return json(data);
}



================================================
FILE: src/app/api/reports/utm/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';
import { getUTM } from '@/queries';
import { reportParms } from '@/lib/schema';

export async function POST(request: Request) {
  const schema = z.object({
    ...reportParms,
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const {
    websiteId,
    dateRange: { startDate, endDate, timezone },
  } = body;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getUTM(websiteId, {
    startDate: new Date(startDate),
    endDate: new Date(endDate),
    timezone,
  });

  return json(data);
}



================================================
FILE: src/app/api/scripts/telemetry/route.ts
================================================
import { CURRENT_VERSION, TELEMETRY_PIXEL } from '@/lib/constants';

export async function GET() {
  if (
    process.env.NODE_ENV !== 'production' ||
    process.env.DISABLE_TELEMETRY ||
    process.env.PRIVATE_MODE
  ) {
    return new Response('/* telemetry disabled */', {
      headers: {
        'content-type': 'text/javascript',
      },
    });
  }

  const script = `
    (()=>{const i=document.createElement('img');
      i.setAttribute('src','${TELEMETRY_PIXEL}?v=${CURRENT_VERSION}');
      i.setAttribute('style','width:0;height:0;position:absolute;pointer-events:none;');
      document.body.appendChild(i);})();
  `;

  return new Response(script.replace(/\s\s+/g, ''), {
    headers: {
      'content-type': 'text/javascript',
    },
  });
}



================================================
FILE: src/app/api/send/route.ts
================================================
import { z } from 'zod';
import { isbot } from 'isbot';
import { startOfHour, startOfMonth } from 'date-fns';
import clickhouse from '@/lib/clickhouse';
import { parseRequest } from '@/lib/request';
import { badRequest, json, forbidden, serverError } from '@/lib/response';
import { fetchWebsite } from '@/lib/load';
import { getClientInfo, hasBlockedIp } from '@/lib/detect';
import { createToken, parseToken } from '@/lib/jwt';
import { secret, uuid, hash } from '@/lib/crypto';
import { COLLECTION_TYPE } from '@/lib/constants';
import { anyObjectParam, urlOrPathParam } from '@/lib/schema';
import { safeDecodeURI, safeDecodeURIComponent } from '@/lib/url';
import { createSession, saveEvent, saveSessionData } from '@/queries';

const schema = z.object({
  type: z.enum(['event', 'identify']),
  payload: z.object({
    website: z.string().uuid(),
    data: anyObjectParam.optional(),
    hostname: z.string().max(100).optional(),
    language: z.string().max(35).optional(),
    referrer: urlOrPathParam.optional(),
    screen: z.string().max(11).optional(),
    title: z.string().optional(),
    url: urlOrPathParam.optional(),
    name: z.string().max(50).optional(),
    tag: z.string().max(50).optional(),
    ip: z.string().ip().optional(),
    userAgent: z.string().optional(),
    timestamp: z.coerce.number().int().optional(),
    id: z.string().optional(),
  }),
});

export async function POST(request: Request) {
  try {
    const { body, error } = await parseRequest(request, schema, { skipAuth: true });

    if (error) {
      return error();
    }

    const { type, payload } = body;

    const {
      website: websiteId,
      hostname,
      screen,
      language,
      url,
      referrer,
      name,
      data,
      title,
      tag,
      timestamp,
      id,
    } = payload;

    // Cache check
    let cache: { websiteId: string; sessionId: string; visitId: string; iat: number } | null = null;
    const cacheHeader = request.headers.get('x-umami-cache');

    if (cacheHeader) {
      const result = await parseToken(cacheHeader, secret());

      if (result) {
        cache = result;
      }
    }

    // Find website
    if (!cache?.websiteId) {
      const website = await fetchWebsite(websiteId);

      if (!website) {
        return badRequest('Website not found.');
      }
    }

    // Client info
    const { ip, userAgent, device, browser, os, country, region, city } = await getClientInfo(
      request,
      payload,
    );

    // Bot check
    if (!process.env.DISABLE_BOT_CHECK && isbot(userAgent)) {
      return json({ beep: 'boop' });
    }

    // IP block
    if (hasBlockedIp(ip)) {
      return forbidden();
    }

    const createdAt = timestamp ? new Date(timestamp * 1000) : new Date();
    const now = Math.floor(new Date().getTime() / 1000);

    const sessionSalt = hash(startOfMonth(createdAt).toUTCString());
    const visitSalt = hash(startOfHour(createdAt).toUTCString());

    const sessionId = id ? uuid(websiteId, id) : uuid(websiteId, ip, userAgent, sessionSalt);

    // Create a session if not found
    if (!clickhouse.enabled && !cache?.sessionId) {
      await createSession(
        {
          id: sessionId,
          websiteId,
          browser,
          os,
          device,
          screen,
          language,
          country,
          region,
          city,
          distinctId: id,
        },
        { skipDuplicates: true },
      );
    }

    // Visit info
    let visitId = cache?.visitId || uuid(sessionId, visitSalt);
    let iat = cache?.iat || now;

    // Expire visit after 30 minutes
    if (!timestamp && now - iat > 1800) {
      visitId = uuid(sessionId, visitSalt);
      iat = now;
    }

    if (type === COLLECTION_TYPE.event) {
      const base = hostname ? `https://${hostname}` : 'https://localhost';
      const currentUrl = new URL(url, base);

      let urlPath =
        currentUrl.pathname === '/undefined' ? '' : currentUrl.pathname + currentUrl.hash;
      const urlQuery = currentUrl.search.substring(1);
      const urlDomain = currentUrl.hostname.replace(/^www./, '');

      let referrerPath: string;
      let referrerQuery: string;
      let referrerDomain: string;

      // UTM Params
      const utmSource = currentUrl.searchParams.get('utm_source');
      const utmMedium = currentUrl.searchParams.get('utm_medium');
      const utmCampaign = currentUrl.searchParams.get('utm_campaign');
      const utmContent = currentUrl.searchParams.get('utm_content');
      const utmTerm = currentUrl.searchParams.get('utm_term');

      // Click IDs
      const gclid = currentUrl.searchParams.get('gclid');
      const fbclid = currentUrl.searchParams.get('fbclid');
      const msclkid = currentUrl.searchParams.get('msclkid');
      const ttclid = currentUrl.searchParams.get('ttclid');
      const lifatid = currentUrl.searchParams.get('li_fat_id');
      const twclid = currentUrl.searchParams.get('twclid');

      if (process.env.REMOVE_TRAILING_SLASH) {
        urlPath = urlPath.replace(/\/(?=(#.*)?$)/, '');
      }

      if (referrer) {
        const referrerUrl = new URL(referrer, base);

        referrerPath = referrerUrl.pathname;
        referrerQuery = referrerUrl.search.substring(1);

        if (referrerUrl.hostname !== 'localhost') {
          referrerDomain = referrerUrl.hostname.replace(/^www\./, '');
        }
      }

      await saveEvent({
        websiteId,
        sessionId,
        visitId,
        createdAt,

        // Page
        pageTitle: safeDecodeURIComponent(title),
        hostname: hostname || urlDomain,
        urlPath: safeDecodeURI(urlPath),
        urlQuery,
        referrerPath: safeDecodeURI(referrerPath),
        referrerQuery,
        referrerDomain,

        // Session
        distinctId: id,
        browser,
        os,
        device,
        screen,
        language,
        country,
        region,
        city,

        // Events
        eventName: name,
        eventData: data,
        tag,

        // UTM
        utmSource,
        utmMedium,
        utmCampaign,
        utmContent,
        utmTerm,

        // Click IDs
        gclid,
        fbclid,
        msclkid,
        ttclid,
        lifatid,
        twclid,
      });
    }

    if (type === COLLECTION_TYPE.identify) {
      if (data) {
        await saveSessionData({
          websiteId,
          sessionId,
          sessionData: data,
          distinctId: id,
          createdAt,
        });
      }
    }

    const token = createToken({ websiteId, sessionId, visitId, iat }, secret());

    return json({ cache: token, sessionId, visitId });
  } catch (e) {
    return serverError(e);
  }
}



================================================
FILE: src/app/api/share/[shareId]/route.ts
================================================
import { json, notFound } from '@/lib/response';
import { createToken } from '@/lib/jwt';
import { secret } from '@/lib/crypto';
import { getSharedWebsite } from '@/queries';

export async function GET(request: Request, { params }: { params: Promise<{ shareId: string }> }) {
  const { shareId } = await params;

  const website = await getSharedWebsite(shareId);

  if (!website) {
    return notFound();
  }

  const data = { websiteId: website.id };
  const token = createToken(data, secret());

  return json({ ...data, token });
}



================================================
FILE: src/app/api/teams/route.ts
================================================
import { z } from 'zod';
import { getRandomChars } from '@/lib/crypto';
import { unauthorized, json } from '@/lib/response';
import { canCreateTeam } from '@/lib/auth';
import { uuid } from '@/lib/crypto';
import { parseRequest } from '@/lib/request';
import { createTeam } from '@/queries';

export async function POST(request: Request) {
  const schema = z.object({
    name: z.string().max(50),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canCreateTeam(auth))) {
    return unauthorized();
  }

  const { name } = body;

  const team = await createTeam(
    {
      id: uuid(),
      name,
      accessCode: `team_${getRandomChars(16)}`,
    },
    auth.user.id,
  );

  return json(team);
}



================================================
FILE: src/app/api/teams/[teamId]/route.ts
================================================
import { z } from 'zod';
import { unauthorized, json, notFound, ok } from '@/lib/response';
import { canDeleteTeam, canUpdateTeam, canViewTeam } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { deleteTeam, getTeam, updateTeam } from '@/queries';

export async function GET(request: Request, { params }: { params: Promise<{ teamId: string }> }) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { teamId } = await params;

  if (!(await canViewTeam(auth, teamId))) {
    return unauthorized();
  }

  const team = await getTeam(teamId, { includeMembers: true });

  if (!team) {
    return notFound('Team not found.');
  }

  return json(team);
}

export async function POST(request: Request, { params }: { params: Promise<{ teamId: string }> }) {
  const schema = z.object({
    name: z.string().max(50).optional(),
    accessCode: z.string().max(50).optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { teamId } = await params;

  if (!(await canUpdateTeam(auth, teamId))) {
    return unauthorized('You must be the owner of this team.');
  }

  const team = await updateTeam(teamId, body);

  return json(team);
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ teamId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { teamId } = await params;

  if (!(await canDeleteTeam(auth, teamId))) {
    return unauthorized('You must be the owner of this team.');
  }

  await deleteTeam(teamId);

  return ok();
}



================================================
FILE: src/app/api/teams/[teamId]/users/route.ts
================================================
import { z } from 'zod';
import { unauthorized, json, badRequest } from '@/lib/response';
import { canAddUserToTeam, canViewTeam } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { pagingParams, roleParam } from '@/lib/schema';
import { createTeamUser, getTeamUser, getTeamUsers } from '@/queries';

export async function GET(request: Request, { params }: { params: Promise<{ teamId: string }> }) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { teamId } = await params;

  if (!(await canViewTeam(auth, teamId))) {
    return unauthorized('You must be the owner of this team.');
  }

  const users = await getTeamUsers(
    {
      where: {
        teamId,
        user: {
          deletedAt: null,
        },
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    },
    query,
  );

  return json(users);
}

export async function POST(request: Request, { params }: { params: Promise<{ teamId: string }> }) {
  const schema = z.object({
    userId: z.string().uuid(),
    role: roleParam,
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { teamId } = await params;

  if (!(await canAddUserToTeam(auth))) {
    return unauthorized();
  }

  const { userId, role } = body;

  const teamUser = await getTeamUser(teamId, userId);

  if (teamUser) {
    return badRequest('User is already a member of the Team.');
  }

  const users = await createTeamUser(userId, teamId, role);

  return json(users);
}



================================================
FILE: src/app/api/teams/[teamId]/users/[userId]/route.ts
================================================
import { canDeleteTeamUser, canUpdateTeam } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { badRequest, json, ok, unauthorized } from '@/lib/response';
import { deleteTeamUser, getTeamUser, updateTeamUser } from '@/queries';
import { z } from 'zod';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ teamId: string; userId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { teamId, userId } = await params;

  if (!(await canUpdateTeam(auth, teamId))) {
    return unauthorized('You must be the owner of this team.');
  }

  const teamUser = await getTeamUser(teamId, userId);

  return json(teamUser);
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ teamId: string; userId: string }> },
) {
  const schema = z.object({
    role: z.string().regex(/team-member|team-view-only|team-manager/),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { teamId, userId } = await params;

  if (!(await canUpdateTeam(auth, teamId))) {
    return unauthorized('You must be the owner of this team.');
  }

  const teamUser = await getTeamUser(teamId, userId);

  if (!teamUser) {
    return badRequest('The User does not exists on this team.');
  }

  const user = await updateTeamUser(teamUser.id, body);

  return json(user);
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ teamId: string; userId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { teamId, userId } = await params;

  if (!(await canDeleteTeamUser(auth, teamId, userId))) {
    return unauthorized('You must be the owner of this team.');
  }

  const teamUser = await getTeamUser(teamId, userId);

  if (!teamUser) {
    return badRequest('The User does not exists on this team.');
  }

  await deleteTeamUser(teamId, userId);

  return ok();
}



================================================
FILE: src/app/api/teams/[teamId]/websites/route.ts
================================================
import { z } from 'zod';
import { unauthorized, json } from '@/lib/response';
import { canViewTeam } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { pagingParams } from '@/lib/schema';
import { getTeamWebsites } from '@/queries';

export async function GET(request: Request, { params }: { params: Promise<{ teamId: string }> }) {
  const schema = z.object({
    ...pagingParams,
  });
  const { teamId } = await params;
  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canViewTeam(auth, teamId))) {
    return unauthorized();
  }

  const websites = await getTeamWebsites(teamId, query);

  return json(websites);
}



================================================
FILE: src/app/api/teams/join/route.ts
================================================
import { z } from 'zod';
import { unauthorized, json, badRequest, notFound } from '@/lib/response';
import { canCreateTeam } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { ROLES } from '@/lib/constants';
import { createTeamUser, findTeam, getTeamUser } from '@/queries';

export async function POST(request: Request) {
  const schema = z.object({
    accessCode: z.string().max(50),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canCreateTeam(auth))) {
    return unauthorized();
  }

  const { accessCode } = body;

  const team = await findTeam({
    where: {
      accessCode,
    },
  });

  if (!team) {
    return notFound('Team not found.');
  }

  const teamUser = await getTeamUser(team.id, auth.user.id);

  if (teamUser) {
    return badRequest('User is already a team member.');
  }

  const user = await createTeamUser(auth.user.id, team.id, ROLES.teamMember);

  return json(user);
}



================================================
FILE: src/app/api/users/route.ts
================================================
import { z } from 'zod';
import { hashPassword, canCreateUser } from '@/lib/auth';
import { ROLES } from '@/lib/constants';
import { uuid } from '@/lib/crypto';
import { parseRequest } from '@/lib/request';
import { unauthorized, json, badRequest } from '@/lib/response';
import { createUser, getUserByUsername } from '@/queries';

export async function POST(request: Request) {
  const schema = z.object({
    id: z.string().uuid().optional(),
    username: z.string().max(255),
    password: z.string(),
    role: z.string().regex(/admin|user|view-only/i),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!(await canCreateUser(auth))) {
    return unauthorized();
  }

  const { id, username, password, role } = body;

  const existingUser = await getUserByUsername(username, { showDeleted: true });

  if (existingUser) {
    return badRequest('User already exists');
  }

  const user = await createUser({
    id: id || uuid(),
    username,
    password: hashPassword(password),
    role: role ?? ROLES.user,
  });

  return json(user);
}



================================================
FILE: src/app/api/users/[userId]/route.ts
================================================
import { canDeleteUser, canUpdateUser, canViewUser, hashPassword } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { badRequest, json, ok, unauthorized } from '@/lib/response';
import { deleteUser, getUser, getUserByUsername, updateUser } from '@/queries';
import { z } from 'zod';

export async function GET(request: Request, { params }: { params: Promise<{ userId: string }> }) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { userId } = await params;

  if (!(await canViewUser(auth, userId))) {
    return unauthorized();
  }

  const user = await getUser(userId);

  return json(user);
}

export async function POST(request: Request, { params }: { params: Promise<{ userId: string }> }) {
  const schema = z.object({
    username: z.string().max(255),
    password: z.string().max(255).optional(),
    role: z
      .string()
      .regex(/admin|user|view-only/i)
      .optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { userId } = await params;

  if (!(await canUpdateUser(auth, userId))) {
    return unauthorized();
  }

  const { username, password, role } = body;

  const user = await getUser(userId);

  const data: any = {};

  if (password) {
    data.password = hashPassword(password);
  }

  // Only admin can change these fields
  if (role && auth.user.isAdmin) {
    data.role = role;
  }

  if (username && auth.user.isAdmin) {
    data.username = username;
  }

  // Check when username changes
  if (data.username && user.username !== data.username) {
    const user = await getUserByUsername(username);

    if (user) {
      return badRequest('User already exists');
    }
  }

  const updated = await updateUser(userId, data);

  return json(updated);
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ userId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { userId } = await params;

  if (!(await canDeleteUser(auth))) {
    return unauthorized();
  }

  if (userId === auth.user.id) {
    return badRequest('You cannot delete yourself.');
  }

  await deleteUser(userId);

  return ok();
}



================================================
FILE: src/app/api/users/[userId]/teams/route.ts
================================================
import { z } from 'zod';
import { pagingParams } from '@/lib/schema';
import { getUserTeams } from '@/queries';
import { unauthorized, json } from '@/lib/response';
import { parseRequest } from '@/lib/request';

export async function GET(request: Request, { params }: { params: Promise<{ userId: string }> }) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { userId } = await params;

  if (auth.user.id !== userId && !auth.user.isAdmin) {
    return unauthorized();
  }

  const teams = await getUserTeams(userId, query);

  return json(teams);
}



================================================
FILE: src/app/api/users/[userId]/usage/route.ts
================================================
import { z } from 'zod';
import { json, unauthorized } from '@/lib/response';
import { getAllUserWebsitesIncludingTeamOwner } from '@/queries/prisma/website';
import { getEventUsage } from '@/queries/sql/events/getEventUsage';
import { getEventDataUsage } from '@/queries/sql/events/getEventDataUsage';
import { parseRequest } from '@/lib/request';

export async function GET(request: Request, { params }: { params: Promise<{ userId: string }> }) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  if (!auth.user.isAdmin) {
    return unauthorized();
  }

  const { userId } = await params;
  const { startAt, endAt } = query;

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const websites = await getAllUserWebsitesIncludingTeamOwner(userId);

  const websiteIds = websites.map(a => a.id);

  const websiteEventUsage = await getEventUsage(websiteIds, startDate, endDate);
  const eventDataUsage = await getEventDataUsage(websiteIds, startDate, endDate);

  const websiteUsage = websites.map(a => ({
    websiteId: a.id,
    websiteName: a.name,
    websiteEventUsage: websiteEventUsage.find(b => a.id === b.websiteId)?.count || 0,
    eventDataUsage: eventDataUsage.find(b => a.id === b.websiteId)?.count || 0,
    deletedAt: a.deletedAt,
  }));

  const usage = websiteUsage.reduce(
    (acc, cv) => {
      acc.websiteEventUsage += cv.websiteEventUsage;
      acc.eventDataUsage += cv.eventDataUsage;

      return acc;
    },
    { websiteEventUsage: 0, eventDataUsage: 0 },
  );

  const filteredWebsiteUsage = websiteUsage.filter(
    a => !a.deletedAt && (a.websiteEventUsage > 0 || a.eventDataUsage > 0),
  );

  return json({
    ...usage,
    websites: filteredWebsiteUsage,
  });
}



================================================
FILE: src/app/api/users/[userId]/websites/route.ts
================================================
import { z } from 'zod';
import { unauthorized, json } from '@/lib/response';
import { getUserWebsites } from '@/queries/prisma/website';
import { pagingParams } from '@/lib/schema';
import { parseRequest } from '@/lib/request';

export async function GET(request: Request, { params }: { params: Promise<{ userId: string }> }) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { userId } = await params;

  if (!auth.user.isAdmin && auth.user.id !== userId) {
    return unauthorized();
  }

  const websites = await getUserWebsites(userId, query);

  return json(websites);
}



================================================
FILE: src/app/api/websites/route.ts
================================================
import { z } from 'zod';
import { canCreateTeamWebsite, canCreateWebsite } from '@/lib/auth';
import { json, unauthorized } from '@/lib/response';
import { uuid } from '@/lib/crypto';
import { parseRequest } from '@/lib/request';
import { createWebsite, getUserWebsites } from '@/queries';
import { pagingParams } from '@/lib/schema';

export async function GET(request: Request) {
  const schema = z.object({ ...pagingParams });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const websites = await getUserWebsites(auth.user.id, query);

  return json(websites);
}

export async function POST(request: Request) {
  const schema = z.object({
    name: z.string().max(100),
    domain: z.string().max(500),
    shareId: z.string().max(50).nullable().optional(),
    teamId: z.string().nullable().optional(),
    id: z.string().uuid().nullable().optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { id, name, domain, shareId, teamId } = body;

  if ((teamId && !(await canCreateTeamWebsite(auth, teamId))) || !(await canCreateWebsite(auth))) {
    return unauthorized();
  }

  const data: any = {
    id: id ?? uuid(),
    createdBy: auth.user.id,
    name,
    domain,
    shareId,
    teamId,
  };

  if (!teamId) {
    data.userId = auth.user.id;
  }

  const website = await createWebsite(data);

  return json(website);
}



================================================
FILE: src/app/api/websites/[websiteId]/route.ts
================================================
import { z } from 'zod';
import { canUpdateWebsite, canDeleteWebsite, canViewWebsite } from '@/lib/auth';
import { SHARE_ID_REGEX } from '@/lib/constants';
import { parseRequest } from '@/lib/request';
import { ok, json, unauthorized, serverError } from '@/lib/response';
import { deleteWebsite, getWebsite, updateWebsite } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const website = await getWebsite(websiteId);

  return json(website);
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    name: z.string().optional(),
    domain: z.string().optional(),
    shareId: z.string().regex(SHARE_ID_REGEX).nullable().optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { name, domain, shareId } = body;

  if (!(await canUpdateWebsite(auth, websiteId))) {
    return unauthorized();
  }

  try {
    const website = await updateWebsite(websiteId, { name, domain, shareId });

    return Response.json(website);
  } catch (e: any) {
    if (e.message.includes('Unique constraint') && e.message.includes('share_id')) {
      return serverError(new Error('That share ID is already taken.'));
    }

    return serverError(e);
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canDeleteWebsite(auth, websiteId))) {
    return unauthorized();
  }

  await deleteWebsite(websiteId);

  return ok();
}



================================================
FILE: src/app/api/websites/[websiteId]/active/route.ts
================================================
import { canViewWebsite } from '@/lib/auth';
import { json, unauthorized } from '@/lib/response';
import { getActiveVisitors } from '@/queries';
import { parseRequest } from '@/lib/request';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const result = await getActiveVisitors(websiteId);

  return json(result);
}



================================================
FILE: src/app/api/websites/[websiteId]/daterange/route.ts
================================================
import { canViewWebsite } from '@/lib/auth';
import { getWebsiteDateRange } from '@/queries';
import { json, unauthorized } from '@/lib/response';
import { parseRequest } from '@/lib/request';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const result = await getWebsiteDateRange(websiteId);

  return json(result);
}



================================================
FILE: src/app/api/websites/[websiteId]/event-data/events/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getEventDataEvents } from '@/queries/sql/events/getEventDataEvents';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    event: z.string().optional(),
  });
  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt, event } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getEventDataEvents(websiteId, {
    startDate,
    endDate,
    event,
  });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/event-data/fields/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getEventDataFields } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getEventDataFields(websiteId, {
    startDate,
    endDate,
  });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/event-data/properties/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getEventDataProperties } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    propertyName: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt, propertyName } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getEventDataProperties(websiteId, { startDate, endDate, propertyName });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/event-data/stats/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getEventDataStats } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    propertyName: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getEventDataStats(websiteId, { startDate, endDate });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/event-data/values/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getEventDataValues } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    eventName: z.string().optional(),
    propertyName: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt, eventName, propertyName } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getEventDataValues(websiteId, {
    startDate,
    endDate,
    eventName,
    propertyName,
  });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/events/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { pagingParams } from '@/lib/schema';
import { getWebsiteEvents } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getWebsiteEvents(websiteId, { startDate, endDate }, query);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/events/series/route.ts
================================================
import { z } from 'zod';
import { parseRequest, getRequestDateRange, getRequestFilters } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { filterParams, timezoneParam, unitParam } from '@/lib/schema';
import { getEventStats } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    unit: unitParam,
    timezone: timezoneParam,
    ...filterParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { timezone } = query;
  const { startDate, endDate, unit } = await getRequestDateRange(query);

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const filters = {
    ...(await getRequestFilters(query)),
    startDate,
    endDate,
    timezone,
    unit,
  };

  const data = await getEventStats(websiteId, filters);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/export/route.ts
================================================
import { z } from 'zod';
import JSZip from 'jszip';
import Papa from 'papaparse';
import { getRequestFilters, parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { pagingParams } from '@/lib/schema';
import { getEventMetrics, getPageviewMetrics, getSessionMetrics } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const filters = {
    ...(await getRequestFilters(query)),
    startDate,
    endDate,
  };

  const [events, pages, referrers, browsers, os, devices, countries] = await Promise.all([
    getEventMetrics(websiteId, 'event', filters),
    getPageviewMetrics(websiteId, 'url', filters),
    getPageviewMetrics(websiteId, 'referrer', filters),
    getSessionMetrics(websiteId, 'browser', filters),
    getSessionMetrics(websiteId, 'os', filters),
    getSessionMetrics(websiteId, 'device', filters),
    getSessionMetrics(websiteId, 'country', filters),
  ]);

  const zip = new JSZip();

  const parse = (data: any) => {
    return Papa.unparse(data, {
      header: true,
      skipEmptyLines: true,
    });
  };

  zip.file('events.csv', parse(events));
  zip.file('pages.csv', parse(pages));
  zip.file('referrers.csv', parse(referrers));
  zip.file('browsers.csv', parse(browsers));
  zip.file('os.csv', parse(os));
  zip.file('devices.csv', parse(devices));
  zip.file('countries.csv', parse(countries));

  const content = await zip.generateAsync({ type: 'nodebuffer' });
  const base64 = content.toString('base64');

  return json({ zip: base64 });
}



================================================
FILE: src/app/api/websites/[websiteId]/metrics/route.ts
================================================
import { z } from 'zod';
import thenby from 'thenby';
import { canViewWebsite } from '@/lib/auth';
import {
  SESSION_COLUMNS,
  EVENT_COLUMNS,
  FILTER_COLUMNS,
  OPERATORS,
  SEARCH_DOMAINS,
  SOCIAL_DOMAINS,
  EMAIL_DOMAINS,
  SHOPPING_DOMAINS,
  VIDEO_DOMAINS,
  PAID_AD_PARAMS,
} from '@/lib/constants';
import { getRequestFilters, getRequestDateRange, parseRequest } from '@/lib/request';
import { json, unauthorized, badRequest } from '@/lib/response';
import {
  getPageviewMetrics,
  getSessionMetrics,
  getEventMetrics,
  getChannelMetrics,
} from '@/queries';
import { filterParams } from '@/lib/schema';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    type: z.string(),
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    limit: z.coerce.number().optional(),
    offset: z.coerce.number().optional(),
    search: z.string().optional(),
    ...filterParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { type, limit, offset, search } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const { startDate, endDate } = await getRequestDateRange(query);
  const column = FILTER_COLUMNS[type] || type;
  const filters = {
    ...(await getRequestFilters(query)),
    startDate,
    endDate,
  };

  if (search) {
    filters[type] = {
      name: type,
      column,
      operator: OPERATORS.contains,
      value: search,
    };
  }

  if (SESSION_COLUMNS.includes(type)) {
    const data = await getSessionMetrics(websiteId, type, filters, limit, offset);

    if (type === 'language') {
      const combined = {};

      for (const { x, y } of data) {
        const key = String(x).toLowerCase().split('-')[0];

        if (combined[key] === undefined) {
          combined[key] = { x: key, y };
        } else {
          combined[key].y += y;
        }
      }

      return json(Object.values(combined));
    }

    return json(data);
  }

  if (EVENT_COLUMNS.includes(type)) {
    let data;

    if (type === 'event') {
      data = await getEventMetrics(websiteId, type, filters, limit, offset);
    } else {
      data = await getPageviewMetrics(websiteId, type, filters, limit, offset);
    }

    return json(data);
  }

  if (type === 'channel') {
    const data = await getChannelMetrics(websiteId, filters);

    const channels = getChannels(data);

    return json(
      Object.keys(channels)
        .map(key => ({ x: key, y: channels[key] }))
        .sort(thenby.firstBy('y', -1)),
    );
  }

  return badRequest();
}

function getChannels(data: { domain: string; query: string; visitors: number }[]) {
  const channels = {
    direct: 0,
    referral: 0,
    affiliate: 0,
    email: 0,
    sms: 0,
    organicSearch: 0,
    organicSocial: 0,
    organicShopping: 0,
    organicVideo: 0,
    paidAds: 0,
    paidSearch: 0,
    paidSocial: 0,
    paidShopping: 0,
    paidVideo: 0,
  };

  const match = (value: string) => {
    return (str: string | RegExp) => {
      return typeof str === 'string' ? value?.includes(str) : (str as RegExp).test(value);
    };
  };

  for (const { domain, query, visitors } of data) {
    if (!domain && !query) {
      channels.direct += Number(visitors);
    }

    const prefix = /utm_medium=(.*cp.*|ppc|retargeting|paid.*)/.test(query) ? 'paid' : 'organic';

    if (PAID_AD_PARAMS.some(match(query))) {
      channels.paidAds += Number(visitors);
    } else if (/utm_medium=(referral|app|link)/.test(query)) {
      channels.referral += Number(visitors);
    } else if (/utm_medium=affiliate/.test(query)) {
      channels.affiliate += Number(visitors);
    } else if (/utm_(source|medium)=sms/.test(query)) {
      channels.sms += Number(visitors);
    } else if (SEARCH_DOMAINS.some(match(domain)) || /utm_medium=organic/.test(query)) {
      channels[`${prefix}Search`] += Number(visitors);
    } else if (
      SOCIAL_DOMAINS.some(match(domain)) ||
      /utm_medium=(social|social-network|social-media|sm|social network|social media)/.test(query)
    ) {
      channels[`${prefix}Social`] += Number(visitors);
    } else if (EMAIL_DOMAINS.some(match(domain)) || /utm_medium=(.*e[-_ ]?mail.*)/.test(query)) {
      channels.email += Number(visitors);
    } else if (
      SHOPPING_DOMAINS.some(match(domain)) ||
      /utm_campaign=(.*(([^a-df-z]|^)shop|shopping).*)/.test(query)
    ) {
      channels[`${prefix}Shopping`] += Number(visitors);
    } else if (VIDEO_DOMAINS.some(match(domain)) || /utm_medium=(.*video.*)/.test(query)) {
      channels[`${prefix}Video`] += Number(visitors);
    }
  }

  return channels;
}



================================================
FILE: src/app/api/websites/[websiteId]/pageviews/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { getRequestFilters, getRequestDateRange, parseRequest } from '@/lib/request';
import { unitParam, timezoneParam, filterParams } from '@/lib/schema';
import { getCompareDate } from '@/lib/date';
import { unauthorized, json } from '@/lib/response';
import { getPageviewStats, getSessionStats } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    unit: unitParam,
    timezone: timezoneParam,
    compare: z.string().optional(),
    ...filterParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { timezone, compare } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const { startDate, endDate, unit } = await getRequestDateRange(query);

  const filters = {
    ...(await getRequestFilters(query)),
    startDate,
    endDate,
    timezone,
    unit,
  };

  const [pageviews, sessions] = await Promise.all([
    getPageviewStats(websiteId, filters),
    getSessionStats(websiteId, filters),
  ]);

  if (compare) {
    const { startDate: compareStartDate, endDate: compareEndDate } = getCompareDate(
      compare,
      startDate,
      endDate,
    );

    const [comparePageviews, compareSessions] = await Promise.all([
      getPageviewStats(websiteId, {
        ...filters,
        startDate: compareStartDate,
        endDate: compareEndDate,
      }),
      getSessionStats(websiteId, {
        ...filters,
        startDate: compareStartDate,
        endDate: compareEndDate,
      }),
    ]);

    return json({
      pageviews,
      sessions,
      startDate,
      endDate,
      compare: {
        pageviews: comparePageviews,
        sessions: compareSessions,
        startDate: compareStartDate,
        endDate: compareEndDate,
      },
    });
  }

  return json({ pageviews, sessions });
}



================================================
FILE: src/app/api/websites/[websiteId]/reports/route.ts
================================================
import { z } from 'zod';
import { canViewWebsite } from '@/lib/auth';
import { getWebsiteReports } from '@/queries';
import { pagingParams } from '@/lib/schema';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { page, pageSize, search } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getWebsiteReports(websiteId, {
    page: +page,
    pageSize: +pageSize,
    search,
  });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/reset/route.ts
================================================
import { canUpdateWebsite } from '@/lib/auth';
import { resetWebsite } from '@/queries';
import { unauthorized, ok } from '@/lib/response';
import { parseRequest } from '@/lib/request';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canUpdateWebsite(auth, websiteId))) {
    return unauthorized();
  }

  await resetWebsite(websiteId);

  return ok();
}



================================================
FILE: src/app/api/websites/[websiteId]/segments/route.ts
================================================
import { canUpdateWebsite, canViewWebsite } from '@/lib/auth';
import { uuid } from '@/lib/crypto';
import { parseRequest } from '@/lib/request';
import { json, unauthorized } from '@/lib/response';
import { segmentTypeParam } from '@/lib/schema';
import { createSegment, getWebsiteSegments } from '@/queries';
import { z } from 'zod';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    type: segmentTypeParam,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { type } = query;

  if (websiteId && !(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const segments = await getWebsiteSegments(websiteId, type);

  return json(segments);
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    type: segmentTypeParam,
    name: z.string().max(200),
    parameters: z.object({}).passthrough(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { type, name, parameters } = body;

  if (!(await canUpdateWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const result = await createSegment({
    id: uuid(),
    websiteId,
    type,
    name,
    parameters,
  } as any);

  return json(result);
}



================================================
FILE: src/app/api/websites/[websiteId]/segments/[segmentId]/route.ts
================================================
import { canDeleteWebsite, canUpdateWebsite, canViewWebsite } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { json, notFound, ok, unauthorized } from '@/lib/response';
import { segmentTypeParam } from '@/lib/schema';
import { deleteSegment, getSegment, updateSegment } from '@/queries';
import { z } from 'zod';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; segmentId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId, segmentId } = await params;

  const segment = await getSegment(segmentId);

  if (websiteId && !(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  return json(segment);
}

export async function POST(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; segmentId: string }> },
) {
  const schema = z.object({
    type: segmentTypeParam,
    name: z.string().max(200),
    parameters: z.object({}).passthrough(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId, segmentId } = await params;
  const { type, name, parameters } = body;

  const segment = await getSegment(segmentId);

  if (!segment) {
    return notFound();
  }

  if (!(await canUpdateWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const result = await updateSegment(segmentId, {
    type,
    name,
    parameters,
  } as any);

  return json(result);
}

export async function DELETE(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; segmentId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId, segmentId } = await params;

  const segment = await getSegment(segmentId);

  if (!segment) {
    return notFound();
  }

  if (!(await canDeleteWebsite(auth, websiteId))) {
    return unauthorized();
  }

  await deleteSegment(segmentId);

  return ok();
}



================================================
FILE: src/app/api/websites/[websiteId]/session-data/properties/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getSessionDataProperties } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    propertyName: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { startAt, endAt, propertyName } = query;
  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getSessionDataProperties(websiteId, { startDate, endDate, propertyName });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/session-data/values/route.ts
================================================
import { canViewWebsite } from '@/lib/auth';
import { parseRequest } from '@/lib/request';
import { json, unauthorized } from '@/lib/response';
import { getSessionDataValues } from '@/queries';
import { z } from 'zod';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    propertyName: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { startAt, endAt, propertyName } = query;
  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getSessionDataValues(websiteId, {
    startDate,
    endDate,
    propertyName,
  });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { pagingParams } from '@/lib/schema';
import { getWebsiteSessions } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getWebsiteSessions(websiteId, { startDate, endDate }, query);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/[sessionId]/route.ts
================================================
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getWebsiteSession } from '@/queries';
import { parseRequest } from '@/lib/request';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; sessionId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId, sessionId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getWebsiteSession(websiteId, sessionId);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/[sessionId]/activity/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getSessionActivity } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; sessionId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId, sessionId } = await params;
  const { startAt, endAt } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getSessionActivity(websiteId, sessionId, startDate, endDate);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/[sessionId]/properties/route.ts
================================================
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getSessionData } from '@/queries';
import { parseRequest } from '@/lib/request';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string; sessionId: string }> },
) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId, sessionId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const data = await getSessionData(websiteId, sessionId);

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/stats/route.ts
================================================
import { z } from 'zod';
import { parseRequest, getRequestDateRange, getRequestFilters } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { filterParams } from '@/lib/schema';
import { getWebsiteSessionStats } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    ...filterParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const { startDate, endDate } = await getRequestDateRange(query);

  const filters = await getRequestFilters(query);

  const metrics = await getWebsiteSessionStats(websiteId, {
    ...filters,
    startDate,
    endDate,
  });

  const data = Object.keys(metrics[0]).reduce((obj, key) => {
    obj[key] = {
      value: Number(metrics[0][key]) || 0,
    };
    return obj;
  }, {});

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/sessions/weekly/route.ts
================================================
import { z } from 'zod';
import { parseRequest } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { pagingParams, timezoneParam } from '@/lib/schema';
import { getWebsiteSessionsWeekly } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    timezone: timezoneParam,
    ...pagingParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { startAt, endAt, timezone } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const startDate = new Date(+startAt);
  const endDate = new Date(+endAt);

  const data = await getWebsiteSessionsWeekly(websiteId, { startDate, endDate, timezone });

  return json(data);
}



================================================
FILE: src/app/api/websites/[websiteId]/stats/route.ts
================================================
import { z } from 'zod';
import { parseRequest, getRequestDateRange, getRequestFilters } from '@/lib/request';
import { unauthorized, json } from '@/lib/response';
import { canViewWebsite } from '@/lib/auth';
import { getCompareDate } from '@/lib/date';
import { filterParams } from '@/lib/schema';
import { getWebsiteStats } from '@/queries';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    compare: z.string().optional(),
    ...filterParams,
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { compare } = query;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const { startDate, endDate } = await getRequestDateRange(query);
  const { startDate: compareStartDate, endDate: compareEndDate } = getCompareDate(
    compare,
    startDate,
    endDate,
  );

  const filters = await getRequestFilters(query);

  const metrics = await getWebsiteStats(websiteId, {
    ...filters,
    startDate,
    endDate,
  });

  const prevPeriod = await getWebsiteStats(websiteId, {
    ...filters,
    startDate: compareStartDate,
    endDate: compareEndDate,
  });

  const stats = Object.keys(metrics[0]).reduce((obj, key) => {
    obj[key] = {
      value: Number(metrics[0][key]) || 0,
      prev: Number(prevPeriod[0][key]) || 0,
    };
    return obj;
  }, {});

  return json(stats);
}



================================================
FILE: src/app/api/websites/[websiteId]/transfer/route.ts
================================================
import { z } from 'zod';
import { canTransferWebsiteToTeam, canTransferWebsiteToUser } from '@/lib/auth';
import { updateWebsite } from '@/queries';
import { parseRequest } from '@/lib/request';
import { badRequest, unauthorized, json } from '@/lib/response';

export async function POST(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    userId: z.string().uuid().optional(),
    teamId: z.string().uuid().optional(),
  });

  const { auth, body, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { userId, teamId } = body;

  if (userId) {
    if (!(await canTransferWebsiteToUser(auth, websiteId, userId))) {
      return unauthorized();
    }

    const website = await updateWebsite(websiteId, {
      userId,
      teamId: null,
    });

    return json(website);
  } else if (teamId) {
    if (!(await canTransferWebsiteToTeam(auth, websiteId, teamId))) {
      return unauthorized();
    }

    const website = await updateWebsite(websiteId, {
      userId: null,
      teamId,
    });

    return json(website);
  }

  return badRequest();
}



================================================
FILE: src/app/api/websites/[websiteId]/values/route.ts
================================================
import { canViewWebsite } from '@/lib/auth';
import { EVENT_COLUMNS, FILTER_COLUMNS, FILTER_GROUPS, SESSION_COLUMNS } from '@/lib/constants';
import { getRequestDateRange, parseRequest } from '@/lib/request';
import { badRequest, json, unauthorized } from '@/lib/response';
import { getWebsiteSegments, getValues } from '@/queries';
import { z } from 'zod';

export async function GET(
  request: Request,
  { params }: { params: Promise<{ websiteId: string }> },
) {
  const schema = z.object({
    type: z.string(),
    startAt: z.coerce.number().int(),
    endAt: z.coerce.number().int(),
    search: z.string().optional(),
  });

  const { auth, query, error } = await parseRequest(request, schema);

  if (error) {
    return error();
  }

  const { websiteId } = await params;
  const { type, search } = query;
  const { startDate, endDate } = await getRequestDateRange(query);

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  if (!SESSION_COLUMNS.includes(type) && !EVENT_COLUMNS.includes(type) && !FILTER_GROUPS[type]) {
    return badRequest('Invalid type.');
  }

  let values;

  if (FILTER_GROUPS[type]) {
    values = (await getWebsiteSegments(websiteId, type)).map(segment => ({ value: segment.name }));
  } else {
    values = await getValues(websiteId, FILTER_COLUMNS[type], startDate, endDate, search);
  }

  return json(values.filter(n => n).sort());
}


