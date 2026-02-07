//
//  APIClient.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine

class APIClient {
    private var baseURL: URL
    private var authToken: String?
    private var apiKey: String?
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let serverType: ServerType

    init(serverURL: String, serverType: ServerType = .selfHosted) throws {
        guard let url = URL(string: serverURL) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url
        self.serverType = serverType

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        self.jsonEncoder = JSONEncoder()
    }

    func setBaseURL(_ urlString: String) throws {
        guard let url = URL(string: urlString) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url
    }

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func clearAuthToken() {
        self.authToken = nil
    }

    func setAPIKey(_ key: String) {
        self.apiKey = key
    }

    // MARK: - Helper Methods

    private func logDebug(_ message: @autoclosure () -> String) {
#if DEBUG
        print(message())
#endif
    }

    private func createRequest(path: String, method: String, body: Encodable? = nil) -> URLRequest {
        let normalizedPath = normalize(path: path)
        // Handle URLs with query parameters correctly
        let apiURL: URL
        if normalizedPath.contains("?") {
            // Path contains query parameters, construct URL directly
            apiURL = URL(string: normalizedPath, relativeTo: baseURL) ?? baseURL.appendingPathComponent(normalizedPath)
        } else {
            // Path is just a path component, use appendingPathComponent
            apiURL = baseURL.appendingPathComponent(normalizedPath)
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        switch serverType {
        case .selfHosted:
            if let token = authToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        case .cloud:
            if let apiKey = apiKey {
                request.addValue(apiKey, forHTTPHeaderField: "x-umami-api-key")
            }
        }

        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
            } catch {
                logDebug("Error encoding request body: \(error)")
            }
        }

        return request
    }

    private func performRequest<T: Decodable>(request: URLRequest) -> AnyPublisher<T, Error> {
        logDebug("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            logDebug("🔑 Headers: \(headers)")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                logDebug("📡 Response Status: \(httpResponse.statusCode) for \(request.url?.absoluteString ?? "unknown")")
                if let responseString = String(data: data, encoding: .utf8) {
                    logDebug("📄 Response Body: \(responseString)")
                }

                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to parse error message from response
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] ?? errorResponse["message"] {
                        throw APIError.serverError(errorMessage)
                    } else {
                        throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .flatMap { data -> AnyPublisher<T, Error> in
                if data.isEmpty, T.self == EmptyResponse.self,
                   let emptyResponse = EmptyResponse() as? T {
                    return Just(emptyResponse)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                return Just(data)
                    .decode(type: T.self, decoder: self.jsonDecoder)
                    .mapError { error -> Error in
                        if let apiError = error as? APIError {
                            return apiError
                        } else if error is DecodingError {
                            self.logDebug("Decoding error: \(error)")
                            return APIError.decodingError
                        } else {
                            return APIError.networkError(error)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .mapError { error -> Error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    self.logDebug("Decoding error: \(error)")
                    return APIError.decodingError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    private func performVoidRequest(request: URLRequest) -> AnyPublisher<Void, Error> {
        logDebug("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            logDebug("🔑 Headers: \(headers)")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                self.logDebug("📡 Response Status: \(httpResponse.statusCode) for \(request.url?.absoluteString ?? "unknown")")
                if let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty {
                    self.logDebug("📄 Response Body: \(responseString)")
                }

                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                       let errorMessage = errorResponse["error"] ?? errorResponse["message"] {
                        throw APIError.serverError(errorMessage)
                    }

                    throw APIError.serverError("Status code: \(httpResponse.statusCode)")
                }

                return ()
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }

    private func normalize(path: String) -> String {
        guard serverType == .cloud else { return path }

        // Separate path from query string for prefix matching
        let components = path.split(separator: "?", maxSplits: 1)
        let pathPart = String(components[0])
        let queryPart = components.count > 1 ? "?" + components[1] : ""

        if pathPart.hasPrefix("/api/") {
            return "/v1/" + pathPart.dropFirst("/api/".count) + queryPart
        }

        if pathPart == "/api" {
            return "/v1" + queryPart
        }

        return path
    }

    private func buildPath(path: String, queryItems: [URLQueryItem]) -> String? {
        var components = URLComponents(string: path)
        let filtered = queryItems.filter { item in
            if let value = item.value {
                return !value.isEmpty
            }
            return false
        }
        components?.queryItems = filtered.isEmpty ? nil : filtered
        return components?.string
    }

    private func dateRangeQueryItems(_ dateRange: DateRange, includeUnit: Bool = false) -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "startAt", value: "\(dateRange.startAt)"),
            URLQueryItem(name: "endAt", value: "\(dateRange.endAt)")
        ]

        if includeUnit {
            items.append(URLQueryItem(name: "unit", value: dateRange.unit))
        }

        if let timezone = dateRange.timezone {
            items.append(URLQueryItem(name: "timezone", value: timezone))
        }

        return items
    }

    // MARK: - Authentication

    func login(username: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        let credentials = AuthCredentials(username: username, password: password)
        let request = createRequest(path: "/api/auth/login", method: "POST", body: credentials)
        return performRequest(request: request)
    }

    func verifyToken() -> AnyPublisher<User, Error> {
        guard authToken != nil else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let request = createRequest(path: "/api/auth/verify", method: "POST")
        return performRequest(request: request)
    }

    func logout() -> AnyPublisher<EmptyResponse, Error> {
        guard authToken != nil else {
            return Just(EmptyResponse()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let request = createRequest(path: "/api/auth/logout", method: "POST")
        return performRequest(request: request)
    }

    // MARK: - Websites

    func getWebsites(page: Int = 1, pageSize: Int = 10) -> AnyPublisher<WebsiteListResponse, Error> {
        var components = URLComponents(string: "/api/websites")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]

        let path = components?.string ?? "/api/websites?page=\(page)&pageSize=\(pageSize)"
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }
    
    func getAllWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        // Start with first page to get total count
        return getWebsites(page: 1, pageSize: 50) // Use larger page size to minimize requests
            .flatMap { firstPageResponse -> AnyPublisher<[WebsiteModel], Error> in
                let totalCount = firstPageResponse.count
                let firstPageData = firstPageResponse.data

                // If all websites fit in first page, return them
                if totalCount <= firstPageData.count {
                    return Just(firstPageData)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                // Calculate how many more pages we need
                let pageSize = 50
                let totalPages = (totalCount + pageSize - 1) / pageSize // Ceiling division

                // Create publishers for remaining pages
                let remainingPagePublishers = (2...totalPages).map { page in
                    self.getWebsites(page: page, pageSize: pageSize)
                        .map { $0.data }
                }

                // Combine all pages
                if remainingPagePublishers.isEmpty {
                    return Just(firstPageData)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Publishers.MergeMany(remainingPagePublishers)
                        .collect()
                        .map { additionalPages in
                            var allWebsites = firstPageData
                            for pageData in additionalPages {
                                allWebsites.append(contentsOf: pageData)
                            }
                            return allWebsites
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func getWebsite(id: String) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "GET")
        return performRequest(request: request)
    }

    func createWebsite(body: CreateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites", method: "POST", body: body)
        return performRequest(request: request)
    }

    func updateWebsite(id: String, body: UpdateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "POST", body: body)
        return performRequest(request: request)
    }

    func deleteWebsite(id: String) -> AnyPublisher<Void, Error> {
        let request = createRequest(path: "/api/websites/\(id)", method: "DELETE")
        return performVoidRequest(request: request)
    }

    func getWebsiteStats(id: String, dateRange: DateRange) -> AnyPublisher<WebsiteStatsResponse, Error> {
        guard let path = buildPath(path: "/api/websites/\(id)/stats", queryItems: dateRangeQueryItems(dateRange)) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteMetrics(id: String, dateRange: DateRange, type: String = "path") -> AnyPublisher<WebsiteMetricsResponse, Error> {
        let queryItems = [
            URLQueryItem(name: "startAt", value: "\(dateRange.startAt)"),
            URLQueryItem(name: "endAt", value: "\(dateRange.endAt)"),
            URLQueryItem(name: "type", value: type)
        ]

        var items = queryItems
        if let timezone = dateRange.timezone {
            items.append(URLQueryItem(name: "timezone", value: timezone))
        }

        guard let path = buildPath(path: "/api/websites/\(id)/metrics", queryItems: items) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsitePageviews(id: String, dateRange: DateRange) -> AnyPublisher<PageviewsResponse, Error> {
        guard let path = buildPath(
            path: "/api/websites/\(id)/pageviews",
            queryItems: dateRangeQueryItems(dateRange, includeUnit: true)
        ) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    // MARK: - Active Users & Realtime

    func getActiveUsers(websiteId: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        let request = createRequest(path: "/api/websites/\(websiteId)/active", method: "GET")
        return performRequest(request: request)
    }

    func getRealtime(websiteId: String, timezone: String?) -> AnyPublisher<RealtimeData, Error> {
        let items = [URLQueryItem(name: "timezone", value: timezone)]
        guard let path = buildPath(path: "/api/realtime/\(websiteId)", queryItems: items) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteEvents(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(contentsOf: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "search", value: search)
        ])

        guard let path = buildPath(path: "/api/websites/\(id)/events", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteEventSeries(
        id: String,
        dateRange: DateRange,
        eventName: String?
    ) -> AnyPublisher<[TimeSeriesData], Error> {
        var queryItems = dateRangeQueryItems(dateRange, includeUnit: true)
        queryItems.append(URLQueryItem(name: "eventName", value: eventName))
        guard let path = buildPath(path: "/api/websites/\(id)/events/series", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteValues(
        id: String,
        type: String,
        dateRange: DateRange,
        search: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(contentsOf: [
            URLQueryItem(name: "type", value: type),
            URLQueryItem(name: "search", value: search)
        ])

        guard let path = buildPath(path: "/api/websites/\(id)/values", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getEventDataEvents(
        id: String,
        dateRange: DateRange,
        event: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(URLQueryItem(name: "event", value: event))
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/events", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getEventDataFields(id: String, dateRange: DateRange) -> AnyPublisher<[FilterValue], Error> {
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/fields", queryItems: dateRangeQueryItems(dateRange)) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getEventDataProperties(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(URLQueryItem(name: "propertyName", value: propertyName))
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/properties", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getEventDataStats(
        id: String,
        dateRange: DateRange
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/stats", queryItems: dateRangeQueryItems(dateRange)) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getEventDataValues(
        id: String,
        dateRange: DateRange,
        eventName: String?,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(contentsOf: [
            URLQueryItem(name: "eventName", value: eventName),
            URLQueryItem(name: "propertyName", value: propertyName)
        ])
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/values", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getSessionDataProperties(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(URLQueryItem(name: "propertyName", value: propertyName))
        guard let path = buildPath(path: "/api/websites/\(id)/session-data/properties", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getSessionDataValues(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(URLQueryItem(name: "propertyName", value: propertyName))
        guard let path = buildPath(path: "/api/websites/\(id)/session-data/values", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSessions(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        var queryItems = dateRangeQueryItems(dateRange)
        queryItems.append(contentsOf: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "search", value: search)
        ])

        guard let path = buildPath(path: "/api/websites/\(id)/sessions", queryItems: queryItems) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSessionStats(
        id: String,
        dateRange: DateRange
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let path = buildPath(path: "/api/websites/\(id)/sessions/stats", queryItems: dateRangeQueryItems(dateRange)) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSessionsWeekly(
        id: String,
        dateRange: DateRange
    ) -> AnyPublisher<[WeeklySessionPoint], Error> {
        guard let path = buildPath(path: "/api/websites/\(id)/sessions/weekly", queryItems: dateRangeQueryItems(dateRange)) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error> {
        let request = createRequest(path: "/api/websites/\(id)/sessions/\(sessionId)", method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSessionActivity(
        id: String,
        sessionId: String,
        dateRange: DateRange
    ) -> AnyPublisher<[AnalyticsRecord], Error> {
        guard let path = buildPath(
            path: "/api/websites/\(id)/sessions/\(sessionId)/activity",
            queryItems: dateRangeQueryItems(dateRange)
        ) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        let request = createRequest(path: path, method: "GET")
        return performRequest(request: request)
    }

    func getWebsiteSessionProperties(
        id: String,
        sessionId: String
    ) -> AnyPublisher<[String: JSONValue], Error> {
        let request = createRequest(path: "/api/websites/\(id)/sessions/\(sessionId)/properties", method: "GET")
        return performRequest(request: request)
    }
}

// MARK: - Helper Structures

struct EmptyResponse: Codable {}

// MARK: - API Errors

enum APIError: Error {
    case invalidURL
    case unauthorized
    case networkError(Error)
    case serverError(String)
    case decodingError
    case unknown

    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the URL and try again."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error processing server response."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
