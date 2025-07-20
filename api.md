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
