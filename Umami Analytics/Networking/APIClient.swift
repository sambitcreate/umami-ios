//
//  APIClient.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import OSLog

class APIClient {
    private var baseURL: URL
    private var authToken: String?
    private var apiKey: String?
    private var shareToken: String?
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let serverType: ServerType
    private let cloudRegion: CloudRegion
    private let urlSession: URLSession
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UmamiAnalytics", category: "APIClient")
    private let maxRetryAttempts = 3

    init(
        serverURL: String,
        serverType: ServerType = .selfHosted,
        cloudRegion: CloudRegion = .global,
        urlSession: URLSession = .shared
    ) throws {
        guard let url = URL(string: serverURL) else {
            throw AuthError.invalidURL
        }
        self.baseURL = url
        self.serverType = serverType
        self.cloudRegion = cloudRegion
        self.urlSession = urlSession

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

    func clearAPIKey() {
        self.apiKey = nil
    }

    func setShareToken(_ token: String) {
        self.shareToken = token
    }

    func clearShareToken() {
        self.shareToken = nil
    }

    // MARK: - Helper Methods

    private func logDebug(_ message: @autoclosure () -> String) {
#if DEBUG
        let resolvedMessage = message()
        logger.debug("\(resolvedMessage, privacy: .public)")
#endif
    }

    private func sanitizedHeaders(_ headers: [String: String]) -> [String: String] {
        var sanitized = headers

        if sanitized["Authorization"] != nil {
            sanitized["Authorization"] = "<redacted>"
        }

        if sanitized["x-umami-api-key"] != nil {
            sanitized["x-umami-api-key"] = "<redacted>"
        }

        if sanitized["x-umami-share-token"] != nil {
            sanitized["x-umami-share-token"] = "<redacted>"
        }

        return sanitized
    }

    private func logResponseBody(_ data: Data) {
        guard let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty else {
            return
        }

        let truncatedBody = responseString.count > 2_000 ? String(responseString.prefix(2_000)) + "…" : responseString
        logDebug("📄 Response Body: \(truncatedBody)")
    }

    private func createRequest(path: String, method: String, body: Encodable? = nil) -> URLRequest {
        let normalizedPath = normalize(path: path)
        let apiURL: URL
        if normalizedPath.contains("?") {
            apiURL = URL(string: normalizedPath, relativeTo: baseURL) ?? baseURL.appendingPathComponent(normalizedPath)
        } else {
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
        case .publicShare:
            if let shareToken = shareToken {
                request.addValue(shareToken, forHTTPHeaderField: "x-umami-share-token")
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

    private func performRequest<T: Decodable & Sendable>(request: URLRequest) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        let value: T = try await self.performRequestAsync(request: request)
                        promise(.success(value))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func performVoidRequest(request: URLRequest) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        try await self.performVoidRequestAsync(request: request)
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func normalize(path: String) -> String {
        guard serverType == .cloud else { return path }

        let components = path.split(separator: "?", maxSplits: 1)
        let pathPart = String(components[0])
        let queryPart = components.count > 1 ? "?" + components[1] : ""

        let versionPrefix: String
        if let regionPath = cloudRegion.pathComponent {
            versionPrefix = "/v1/\(regionPath)"
        } else {
            versionPrefix = "/v1"
        }

        if pathPart.hasPrefix("/api/") {
            return versionPrefix + "/" + pathPart.dropFirst("/api/".count) + queryPart
        }

        if pathPart == "/api" {
            return versionPrefix + queryPart
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

    private func retryDelay(for attempt: Int, retryAfter: TimeInterval?) -> UInt64 {
        let baseDelay = retryAfter ?? min(pow(2.0, Double(attempt)) * 0.35, 4.0)
        let jitter = Double.random(in: 0...0.25)
        return UInt64((baseDelay + jitter) * 1_000_000_000)
    }

    private func retryAfterInterval(from response: HTTPURLResponse) -> TimeInterval? {
        guard let value = response.value(forHTTPHeaderField: "Retry-After"),
              let seconds = TimeInterval(value) else {
            return nil
        }

        return seconds
    }

    private func parseAPIError(data: Data, response: HTTPURLResponse) -> APIError {
        if response.statusCode == 401 {
            return .unauthorized
        }

        if response.statusCode == 429 {
            return .rateLimited(retryAfter: retryAfterInterval(from: response))
        }

        if let errorMessage = parseErrorMessage(from: data) {
            return .serverError(errorMessage)
        }

        return .serverError("Status code: \(response.statusCode)")
    }

    private func shouldRetry(statusCode: Int) -> Bool {
        statusCode == 429 || (500...599).contains(statusCode)
    }

    private func logRequest(_ request: URLRequest) {
        logDebug("🌐 API Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        if let headers = request.allHTTPHeaderFields {
            logDebug("🔑 Headers: \(sanitizedHeaders(headers))")
        }
    }

    private func logResponse(_ response: HTTPURLResponse, request: URLRequest, data: Data) {
        logDebug("📡 Response Status: \(response.statusCode) for \(request.url?.absoluteString ?? "unknown")")
        logResponseBody(data)
    }

    private func performDecodedRequestAsync<T: Decodable & Sendable>(request: URLRequest) async throws -> T {
        var attempt = 0

        while true {
            attempt += 1
            logRequest(request)

            do {
                let (data, response) = try await urlSession.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }

                logResponse(httpResponse, request: request, data: data)

                if (200...299).contains(httpResponse.statusCode) {
                    if data.isEmpty, T.self == EmptyResponse.self, let empty = EmptyResponse() as? T {
                        return empty
                    }

                    do {
                        return try jsonDecoder.decode(T.self, from: data)
                    } catch {
                        logDebug("Decoding error: \(error)")
                        throw APIError.decodingError
                    }
                }

                let apiError = parseAPIError(data: data, response: httpResponse)
                if shouldRetry(statusCode: httpResponse.statusCode), attempt < maxRetryAttempts {
                    try? await Task.sleep(nanoseconds: retryDelay(for: attempt, retryAfter: retryAfterInterval(from: httpResponse)))
                    continue
                }

                throw apiError
            } catch let apiError as APIError {
                throw apiError
            } catch {
                if Task.isCancelled || error is CancellationError {
                    throw CancellationError()
                }
                if attempt < maxRetryAttempts {
                    try? await Task.sleep(nanoseconds: retryDelay(for: attempt, retryAfter: nil))
                    if Task.isCancelled { throw CancellationError() }
                    continue
                }
                throw APIError.networkError(error.localizedDescription)
            }
        }
    }

    private func performRequestAsync<T: Decodable & Sendable>(request: URLRequest) async throws -> T {
        try await performDecodedRequestAsync(request: request)
    }

    private func performVoidRequestAsync(request: URLRequest) async throws {
        let _: EmptyResponse = try await performDecodedRequestAsync(request: request)
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

    private func filteredQueryItems(
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default,
        includeUnit: Bool = false,
        extraItems: [URLQueryItem] = []
    ) -> [URLQueryItem] {
        var items = dateRangeQueryItems(dateRange, includeUnit: includeUnit)
        items.append(contentsOf: query.queryItems)
        items.append(contentsOf: extraItems)
        return items
    }

    private func parseErrorMessage(from data: Data) -> String? {
        guard let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let message = payload["message"] as? String, !message.isEmpty {
            return message
        }

        if let error = payload["error"] as? String, !error.isEmpty {
            return error
        }

        if let errorObject = payload["error"] as? [String: Any] {
            if let message = errorObject["message"] as? String, !message.isEmpty {
                return message
            }

            if let code = errorObject["code"] as? String, !code.isEmpty {
                return code
            }
        }

        return nil
    }

    // MARK: - Authentication & Bootstrap

    private func asyncPublisher<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                Task {
                    do {
                        promise(.success(try await operation()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func login(username: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        asyncPublisher {
            try await self.loginAsync(username: username, password: password)
        }
    }

    func verifyToken() -> AnyPublisher<User, Error> {
        asyncPublisher {
            try await self.verifyTokenAsync()
        }
    }

    func logout() -> AnyPublisher<EmptyResponse, Error> {
        asyncPublisher {
            try await self.logoutAsync()
            return EmptyResponse()
        }
    }

    func getServerConfig() -> AnyPublisher<ServerConfig, Error> {
        asyncPublisher {
            try await self.getServerConfigAsync()
        }
    }

    func getCurrentUser() -> AnyPublisher<User, Error> {
        asyncPublisher {
            try await self.getCurrentUserAsync()
        }
    }

    func getMyTeams(page: Int = 1, pageSize: Int = 100) -> AnyPublisher<[WorkspaceTeam], Error> {
        asyncPublisher {
            try await self.getMyTeamsAsync(page: page, pageSize: pageSize)
        }
    }

    func getShareSession(shareId: String) -> AnyPublisher<ShareBootstrapResponse, Error> {
        asyncPublisher {
            try await self.getShareSessionAsync(shareId: shareId)
        }
    }

    // MARK: - Websites

    func getWebsites(page: Int = 1, pageSize: Int = 10) -> AnyPublisher<WebsiteListResponse, Error> {
        asyncPublisher {
            try await self.getWebsitesAsync(page: page, pageSize: pageSize)
        }
    }

    func getAllWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        asyncPublisher {
            try await self.getAllWebsitesAsync()
        }
    }

    func getAllAccessibleWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        asyncPublisher {
            try await self.getAllAccessibleWebsitesAsync()
        }
    }

    func getWebsite(id: String) -> AnyPublisher<WebsiteModel, Error> {
        asyncPublisher {
            try await self.getWebsiteAsync(id: id)
        }
    }

    func createWebsite(body: CreateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        asyncPublisher {
            try await self.createWebsiteAsync(body: body)
        }
    }

    func updateWebsite(id: String, body: UpdateWebsiteRequest) -> AnyPublisher<WebsiteModel, Error> {
        asyncPublisher {
            try await self.updateWebsiteAsync(id: id, body: body)
        }
    }

    func deleteWebsite(id: String) -> AnyPublisher<Void, Error> {
        asyncPublisher {
            try await self.deleteWebsiteAsync(id: id)
        }
    }

    func resetWebsite(id: String) -> AnyPublisher<Void, Error> {
        asyncPublisher {
            try await self.resetWebsiteAsync(id: id)
        }
    }

    func transferWebsite(id: String, body: TransferWebsiteRequest) -> AnyPublisher<Void, Error> {
        asyncPublisher {
            try await self.transferWebsiteAsync(id: id, body: body)
        }
    }

    func getWebsiteStats(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<WebsiteStatsResponse, Error> {
        asyncPublisher {
            try await self.getWebsiteStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getWebsiteMetrics(
        id: String,
        dateRange: DateRange,
        type: String = "path",
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        asyncPublisher {
            try await self.getWebsiteMetricsAsync(id: id, dateRange: dateRange, type: type, query: query)
        }
    }

    func getWebsiteExpandedMetrics(
        id: String,
        dateRange: DateRange,
        type: String = "path",
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[ExpandedMetricItem], Error> {
        asyncPublisher {
            try await self.getWebsiteExpandedMetricsAsync(id: id, dateRange: dateRange, type: type, query: query)
        }
    }

    func getWebsitePageviews(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PageviewsResponse, Error> {
        asyncPublisher {
            try await self.getWebsitePageviewsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getWebsiteDateRange(id: String) -> AnyPublisher<WebsiteDateRangeResponse, Error> {
        asyncPublisher {
            try await self.getWebsiteDateRangeAsync(id: id)
        }
    }

    func exportWebsite(id: String) -> AnyPublisher<WebsiteExportResponse, Error> {
        asyncPublisher {
            try await self.exportWebsiteAsync(id: id)
        }
    }

    // MARK: - Active Users & Realtime

    func getActiveUsers(websiteId: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        asyncPublisher {
            try await self.getActiveUsersAsync(websiteId: websiteId)
        }
    }

    func getRealtime(websiteId: String, timezone: String?) -> AnyPublisher<RealtimeData, Error> {
        asyncPublisher {
            try await self.getRealtimeAsync(websiteId: websiteId, timezone: timezone)
        }
    }

    // MARK: - Events

    func getWebsiteEvents(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        asyncPublisher {
            try await self.getWebsiteEventsAsync(
                id: id,
                dateRange: dateRange,
                page: page,
                pageSize: pageSize,
                search: search,
                query: query
            )
        }
    }

    func getWebsiteEventSeries(
        id: String,
        dateRange: DateRange,
        eventName: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[TimeSeriesData], Error> {
        asyncPublisher {
            try await self.getWebsiteEventSeriesAsync(id: id, dateRange: dateRange, eventName: eventName, query: query)
        }
    }

    func getWebsiteEventStats(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<EventStatsResponse, Error> {
        asyncPublisher {
            try await self.getWebsiteEventStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getWebsiteValues(
        id: String,
        type: String,
        dateRange: DateRange,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getWebsiteValuesAsync(id: id, type: type, dateRange: dateRange, search: search, query: query)
        }
    }

    // MARK: - Event Data

    func getEventDataEvents(
        id: String,
        dateRange: DateRange,
        event: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getEventDataEventsAsync(id: id, dateRange: dateRange, event: event, query: query)
        }
    }

    func getEventData(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        asyncPublisher {
            try await self.getEventDataAsync(id: id, dateRange: dateRange, page: page, pageSize: pageSize, query: query)
        }
    }

    func getEventDataDetail(id: String, eventId: String) -> AnyPublisher<[AnalyticsRecord], Error> {
        asyncPublisher {
            try await self.getEventDataDetailAsync(id: id, eventId: eventId)
        }
    }

    func getEventDataPivot(
        id: String,
        dateRange: DateRange,
        eventName: String,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        asyncPublisher {
            try await self.getEventDataPivotAsync(id: id, dateRange: dateRange, eventName: eventName, page: page, pageSize: pageSize, query: query)
        }
    }

    func getEventDataFields(id: String, dateRange: DateRange) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getEventDataFieldsAsync(id: id, dateRange: dateRange)
        }
    }

    func getEventDataProperties(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getEventDataPropertiesAsync(id: id, dateRange: dateRange, propertyName: propertyName)
        }
    }

    func getEventDataStats(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[String: MetricValue], Error> {
        asyncPublisher {
            try await self.getEventDataStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getEventDataValues(
        id: String,
        dateRange: DateRange,
        eventName: String?,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getEventDataValuesAsync(id: id, dateRange: dateRange, eventName: eventName, propertyName: propertyName)
        }
    }

    func getSessionDataProperties(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getSessionDataPropertiesAsync(id: id, dateRange: dateRange, propertyName: propertyName)
        }
    }

    func getSessionDataValues(
        id: String,
        dateRange: DateRange,
        propertyName: String?
    ) -> AnyPublisher<[FilterValue], Error> {
        asyncPublisher {
            try await self.getSessionDataValuesAsync(id: id, dateRange: dateRange, propertyName: propertyName)
        }
    }

    func getSessionDataPivot(
        id: String,
        dateRange: DateRange,
        propertyName: String,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        asyncPublisher {
            try await self.getSessionDataPivotAsync(id: id, dateRange: dateRange, propertyName: propertyName, page: page, pageSize: pageSize, query: query)
        }
    }

    func getSessionDataStats(
        id: String,
        dateRange: DateRange,
        propertyName: String,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[AnalyticsRecord], Error> {
        asyncPublisher {
            try await self.getSessionDataStatsAsync(id: id, dateRange: dateRange, propertyName: propertyName, query: query)
        }
    }

    // MARK: - Sessions

    func getWebsiteSessions(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        asyncPublisher {
            try await self.getWebsiteSessionsAsync(
                id: id,
                dateRange: dateRange,
                page: page,
                pageSize: pageSize,
                search: search,
                query: query
            )
        }
    }

    func getWebsiteSessionStats(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[String: MetricValue], Error> {
        asyncPublisher {
            try await self.getWebsiteSessionStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getWebsiteSessionsWeekly(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[WeeklySessionPoint], Error> {
        asyncPublisher {
            try await self.getWebsiteSessionsWeeklyAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func getWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error> {
        asyncPublisher {
            try await self.getWebsiteSessionAsync(id: id, sessionId: sessionId)
        }
    }

    func getWebsiteSessionActivity(
        id: String,
        sessionId: String,
        dateRange: DateRange
    ) -> AnyPublisher<[AnalyticsRecord], Error> {
        asyncPublisher {
            try await self.getWebsiteSessionActivityAsync(id: id, sessionId: sessionId, dateRange: dateRange)
        }
    }

    func getWebsiteSessionProperties(
        id: String,
        sessionId: String
    ) -> AnyPublisher<[String: JSONValue], Error> {
        asyncPublisher {
            try await self.getWebsiteSessionPropertiesAsync(id: id, sessionId: sessionId)
        }
    }

    // MARK: - Reports, Segments, Assets

    func getWebsiteReports(websiteId: String, page: Int = 1, pageSize: Int = 50) -> AnyPublisher<PaginatedResponse<SavedReport>, Error> {
        asyncPublisher {
            try await self.getWebsiteReportsAsync(websiteId: websiteId, page: page, pageSize: pageSize)
        }
    }

    func getWebsiteSegments(websiteId: String, type: SegmentType? = nil) -> AnyPublisher<[SegmentDefinition], Error> {
        asyncPublisher {
            try await self.getWebsiteSegmentsAsync(websiteId: websiteId, type: type)
        }
    }

    func getLinks(page: Int = 1, pageSize: Int = 50, search: String? = nil, teamId: String? = nil) -> AnyPublisher<PaginatedResponse<TrackedAsset>, Error> {
        asyncPublisher {
            try await self.getLinksAsync(page: page, pageSize: pageSize, search: search, teamId: teamId)
        }
    }

    func getPixels(page: Int = 1, pageSize: Int = 50, search: String? = nil, teamId: String? = nil) -> AnyPublisher<PaginatedResponse<TrackedAsset>, Error> {
        asyncPublisher {
            try await self.getPixelsAsync(page: page, pageSize: pageSize, search: search, teamId: teamId)
        }
    }

    // MARK: - Async Authentication & Bootstrap

    func loginAsync(username: String, password: String) async throws -> AuthResponse {
        let credentials = AuthCredentials(username: username, password: password)
        let request = createRequest(path: "/api/auth/login", method: "POST", body: credentials)
        return try await performRequestAsync(request: request)
    }

    func verifyTokenAsync() async throws -> User {
        guard authToken != nil else { throw APIError.unauthorized }
        let request = createRequest(path: "/api/auth/verify", method: "POST")
        return try await performRequestAsync(request: request)
    }

    func logoutAsync() async throws {
        guard authToken != nil else { return }
        let request = createRequest(path: "/api/auth/logout", method: "POST")
        try await performVoidRequestAsync(request: request)
    }

    func getServerConfigAsync() async throws -> ServerConfig {
        let request = createRequest(path: "/api/config", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getCurrentUserAsync() async throws -> User {
        let request = createRequest(path: "/api/me", method: "GET")
        let response: CurrentUserResponse = try await performRequestAsync(request: request)
        return response.user
    }

    func getMyTeamsAsync(page: Int = 1, pageSize: Int = 100) async throws -> [WorkspaceTeam] {
        var components = URLComponents(string: "/api/me/teams")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        let path = components?.string ?? "/api/me/teams?page=\(page)&pageSize=\(pageSize)"
        let request = createRequest(path: path, method: "GET")
        let response: PaginatedResponse<WorkspaceTeam> = try await performRequestAsync(request: request)
        return response.data
    }

    func getShareSessionAsync(shareId: String) async throws -> ShareBootstrapResponse {
        let request = createRequest(path: "/api/share/\(shareId)", method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Websites

    func getWebsitesAsync(page: Int = 1, pageSize: Int = 10) async throws -> WebsiteListResponse {
        var components = URLComponents(string: "/api/websites")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        let path = components?.string ?? "/api/websites?page=\(page)&pageSize=\(pageSize)"
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getAccessibleWebsitesAsync(page: Int = 1, pageSize: Int = 50) async throws -> WebsiteListResponse {
        var components = URLComponents(string: "/api/me/websites")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "includeTeams", value: "true")
        ]
        let path = components?.string ?? "/api/me/websites?page=\(page)&pageSize=\(pageSize)&includeTeams=true"
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getAllWebsitesAsync() async throws -> [WebsiteModel] {
        let firstPage = try await getWebsitesAsync(page: 1, pageSize: 50)
        if firstPage.count <= firstPage.data.count {
            return firstPage.data
        }

        let pageSize = 50
        let totalPages = (firstPage.count + pageSize - 1) / pageSize

        var allWebsites = firstPage.data
        for page in 2...totalPages {
            try Task.checkCancellation()
            let response = try await getWebsitesAsync(page: page, pageSize: pageSize)
            allWebsites.append(contentsOf: response.data)
        }

        return allWebsites
    }

    func getAllAccessibleWebsitesAsync() async throws -> [WebsiteModel] {
        do {
            let firstPage = try await getAccessibleWebsitesAsync(page: 1, pageSize: 50)
            if firstPage.count <= firstPage.data.count {
                return firstPage.data
            }

            let pageSize = 50
            let totalPages = (firstPage.count + pageSize - 1) / pageSize

            var allWebsites = firstPage.data
            for page in 2...totalPages {
                try Task.checkCancellation()
                let response = try await getAccessibleWebsitesAsync(page: page, pageSize: pageSize)
                allWebsites.append(contentsOf: response.data)
            }

            return allWebsites
        } catch {
            return try await getAllWebsitesAsync()
        }
    }

    func getWebsiteAsync(id: String) async throws -> WebsiteModel {
        let request = createRequest(path: "/api/websites/\(id)", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func createWebsiteAsync(body: CreateWebsiteRequest) async throws -> WebsiteModel {
        let request = createRequest(path: "/api/websites", method: "POST", body: body)
        return try await performRequestAsync(request: request)
    }

    func updateWebsiteAsync(id: String, body: UpdateWebsiteRequest) async throws -> WebsiteModel {
        let request = createRequest(path: "/api/websites/\(id)", method: "POST", body: body)
        return try await performRequestAsync(request: request)
    }

    func deleteWebsiteAsync(id: String) async throws {
        let request = createRequest(path: "/api/websites/\(id)", method: "DELETE")
        try await performVoidRequestAsync(request: request)
    }

    func resetWebsiteAsync(id: String) async throws {
        let request = createRequest(path: "/api/websites/\(id)/reset", method: "POST")
        try await performVoidRequestAsync(request: request)
    }

    func transferWebsiteAsync(id: String, body: TransferWebsiteRequest) async throws {
        let request = createRequest(path: "/api/websites/\(id)/transfer", method: "POST", body: body)
        try await performVoidRequestAsync(request: request)
    }

    // MARK: - Async Stats & Metrics

    func getWebsiteStatsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> WebsiteStatsResponse {
        guard let path = buildPath(path: "/api/websites/\(id)/stats", queryItems: filteredQueryItems(dateRange: dateRange, query: query)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteMetricsAsync(
        id: String,
        dateRange: DateRange,
        type: String = "path",
        query: AnalyticsQueryOptions = .default
    ) async throws -> WebsiteMetricsResponse {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [URLQueryItem(name: "type", value: type)]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/metrics", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteExpandedMetricsAsync(
        id: String,
        dateRange: DateRange,
        type: String = "path",
        query: AnalyticsQueryOptions = .default
    ) async throws -> [ExpandedMetricItem] {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [URLQueryItem(name: "type", value: type)]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/metrics/expanded", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsitePageviewsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PageviewsResponse {
        guard let path = buildPath(
            path: "/api/websites/\(id)/pageviews",
            queryItems: filteredQueryItems(dateRange: dateRange, query: query, includeUnit: true)
        ) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteDateRangeAsync(id: String) async throws -> WebsiteDateRangeResponse {
        let request = createRequest(path: "/api/websites/\(id)/daterange", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func exportWebsiteAsync(id: String) async throws -> WebsiteExportResponse {
        let request = createRequest(path: "/api/websites/\(id)/export", method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Active Users & Realtime

    func getActiveUsersAsync(websiteId: String) async throws -> ActiveUsersResponse {
        let request = createRequest(path: "/api/websites/\(websiteId)/active", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getRealtimeAsync(websiteId: String, timezone: String?) async throws -> RealtimeData {
        let items = [URLQueryItem(name: "timezone", value: timezone)]
        guard let path = buildPath(path: "/api/realtime/\(websiteId)", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Events

    func getWebsiteEventsAsync(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PaginatedResponse<AnalyticsRecord> {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)"),
                URLQueryItem(name: "search", value: search)
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/events", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteEventSeriesAsync(
        id: String,
        dateRange: DateRange,
        eventName: String?,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [TimeSeriesData] {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            includeUnit: true,
            extraItems: [URLQueryItem(name: "event", value: eventName)]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/events/series", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteEventStatsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> EventStatsResponse {
        guard let path = buildPath(path: "/api/websites/\(id)/events/stats", queryItems: filteredQueryItems(dateRange: dateRange, query: query)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteValuesAsync(
        id: String,
        type: String,
        dateRange: DateRange,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [FilterValue] {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "search", value: search)
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/values", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Event Data

    func getEventDataAsync(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PaginatedResponse<AnalyticsRecord> {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/event-data", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataDetailAsync(id: String, eventId: String) async throws -> [AnalyticsRecord] {
        let request = createRequest(path: "/api/websites/\(id)/event-data/\(eventId)", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataPivotAsync(
        id: String,
        dateRange: DateRange,
        eventName: String,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PaginatedResponse<AnalyticsRecord> {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "eventName", value: eventName),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/event-data-pivot", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataEventsAsync(
        id: String,
        dateRange: DateRange,
        event: String?,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [FilterValue] {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [URLQueryItem(name: "event", value: event)]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/events", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataFieldsAsync(id: String, dateRange: DateRange) async throws -> [FilterValue] {
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/fields", queryItems: dateRangeQueryItems(dateRange)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataPropertiesAsync(id: String, dateRange: DateRange, propertyName: String?) async throws -> [FilterValue] {
        guard let path = buildPath(
            path: "/api/websites/\(id)/event-data/properties",
            queryItems: dateRangeQueryItems(dateRange) + [URLQueryItem(name: "propertyName", value: propertyName)]
        ) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getEventDataStatsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [String: MetricValue] {
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/stats", queryItems: filteredQueryItems(dateRange: dateRange, query: query)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        let response: MetricMapResponse = try await performRequestAsync(request: request)
        return response.metrics
    }

    func getEventDataValuesAsync(id: String, dateRange: DateRange, eventName: String?, propertyName: String?) async throws -> [FilterValue] {
        let items = dateRangeQueryItems(dateRange) + [
            URLQueryItem(name: "event", value: eventName),
            URLQueryItem(name: "propertyName", value: propertyName)
        ]
        guard let path = buildPath(path: "/api/websites/\(id)/event-data/values", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Session Data

    func getSessionDataPropertiesAsync(id: String, dateRange: DateRange, propertyName: String?) async throws -> [FilterValue] {
        guard let path = buildPath(
            path: "/api/websites/\(id)/session-data/properties",
            queryItems: dateRangeQueryItems(dateRange) + [URLQueryItem(name: "propertyName", value: propertyName)]
        ) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getSessionDataValuesAsync(id: String, dateRange: DateRange, propertyName: String?) async throws -> [FilterValue] {
        guard let path = buildPath(
            path: "/api/websites/\(id)/session-data/values",
            queryItems: dateRangeQueryItems(dateRange) + [URLQueryItem(name: "propertyName", value: propertyName)]
        ) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getSessionDataPivotAsync(
        id: String,
        dateRange: DateRange,
        propertyName: String,
        page: Int,
        pageSize: Int,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PaginatedResponse<AnalyticsRecord> {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "propertyName", value: propertyName),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/session-data-pivot", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getSessionDataStatsAsync(
        id: String,
        dateRange: DateRange,
        propertyName: String,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [AnalyticsRecord] {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [URLQueryItem(name: "propertyName", value: propertyName)]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/session-data/stats", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    // MARK: - Async Sessions

    func getWebsiteSessionsAsync(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) async throws -> PaginatedResponse<AnalyticsRecord> {
        let items = filteredQueryItems(
            dateRange: dateRange,
            query: query,
            extraItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)"),
                URLQueryItem(name: "search", value: search)
            ]
        )
        guard let path = buildPath(path: "/api/websites/\(id)/sessions", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteSessionStatsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [String: MetricValue] {
        guard let path = buildPath(path: "/api/websites/\(id)/sessions/stats", queryItems: filteredQueryItems(dateRange: dateRange, query: query)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteSessionsWeeklyAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> [WeeklySessionPoint] {
        guard let path = buildPath(path: "/api/websites/\(id)/sessions/weekly", queryItems: filteredQueryItems(dateRange: dateRange, query: query)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        let response: WeeklySessionsResponse = try await performRequestAsync(request: request)
        return response.data
    }

    func getWebsiteSessionAsync(id: String, sessionId: String) async throws -> AnalyticsRecord {
        let request = createRequest(path: "/api/websites/\(id)/sessions/\(sessionId)", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteSessionActivityAsync(id: String, sessionId: String, dateRange: DateRange) async throws -> [AnalyticsRecord] {
        guard let path = buildPath(path: "/api/websites/\(id)/sessions/\(sessionId)/activity", queryItems: dateRangeQueryItems(dateRange)) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteSessionPropertiesAsync(id: String, sessionId: String) async throws -> [String: JSONValue] {
        let request = createRequest(path: "/api/websites/\(id)/sessions/\(sessionId)/properties", method: "GET")
        let response: SessionPropertiesResponse = try await performRequestAsync(request: request)
        return response.properties
    }

    // MARK: - Async Reports, Segments, Assets

    func getWebsiteReportsAsync(websiteId: String, page: Int = 1, pageSize: Int = 50) async throws -> PaginatedResponse<SavedReport> {
        var components = URLComponents(string: "/api/websites/\(websiteId)/reports")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        let request = createRequest(path: components?.string ?? "/api/websites/\(websiteId)/reports", method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getWebsiteSegmentsAsync(websiteId: String, type: SegmentType? = nil) async throws -> [SegmentDefinition] {
        let items = [URLQueryItem(name: "type", value: type?.rawValue)]
        guard let path = buildPath(path: "/api/websites/\(websiteId)/segments", queryItems: items) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        let response: PaginatedResponse<SegmentDefinition> = try await performRequestAsync(request: request)
        return response.data
    }

    func getLinksAsync(page: Int = 1, pageSize: Int = 50, search: String? = nil, teamId: String? = nil) async throws -> PaginatedResponse<TrackedAsset> {
        guard let path = buildPath(path: "/api/links", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "teamId", value: teamId)
        ]) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }

    func getPixelsAsync(page: Int = 1, pageSize: Int = 50, search: String? = nil, teamId: String? = nil) async throws -> PaginatedResponse<TrackedAsset> {
        guard let path = buildPath(path: "/api/pixels", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "teamId", value: teamId)
        ]) else {
            throw APIError.invalidURL
        }
        let request = createRequest(path: path, method: "GET")
        return try await performRequestAsync(request: request)
    }
}

// MARK: - Helper Structures

struct EmptyResponse: Codable, Sendable {}

// MARK: - API Errors

enum APIError: Error, Sendable {
    case invalidURL
    case unauthorized
    case rateLimited(retryAfter: TimeInterval?)
    case networkError(String)
    case serverError(String)
    case decodingError
    case unknown

    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the URL and try again."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .rateLimited(let retryAfter):
            if let retryAfter, retryAfter > 0 {
                return "Rate limited by Umami Cloud. Try again in \(Int(retryAfter.rounded())) seconds."
            }
            return "Rate limited by Umami Cloud. Please try again shortly."
        case .networkError(let description):
            return "Network error: \(description)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error processing server response."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
