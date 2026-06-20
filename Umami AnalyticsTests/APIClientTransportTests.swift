import Foundation
import Testing
@testable import Umami_Analytics

@Suite(.serialized)
struct APIClientTransportTests {

    @Test func selfHostedStatsRequestPreservesBasePathAndBearerAuth() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        {
          "pageviews": 10,
          "visitors": 4,
          "visits": 5,
          "bounces": 1,
          "totaltime": 90
        }
        """)
        let client = try APIClient(
            serverURL: "https://self.example.com/umami",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAuthToken("self-token")

        var query = AnalyticsQueryOptions(compare: .previous, filters: [:])
        query.setFilter(.path, value: " /docs ")
        query.setFilter(.browser, value: "   ")

        let response = try await client.getWebsiteStatsAsync(
            id: "site-1",
            dateRange: DateRange(startAt: 100, endAt: 200, unit: "day", timezone: "America/New_York"),
            query: query
        )

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(response.pageviews == 10)
        #expect(request.httpMethod == "GET")
        #expect(request.url?.path == "/umami/api/websites/site-1/stats")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer self-token")
        #expect(request.value(forHTTPHeaderField: "x-umami-api-key") == nil)

        let queryItems = request.url?.queryItems ?? [:]
        #expect(queryItems["startAt"] == "100")
        #expect(queryItems["endAt"] == "200")
        #expect(queryItems["timezone"] == "America/New_York")
        #expect(queryItems["compare"] == nil)
        #expect(queryItems["path"] == "/docs")
        #expect(queryItems["browser"] == nil)
    }

    @Test func cloudRequestsMapAPIToRegionV1AndUseAPIKeyHeader() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        {
          "id": "created-site",
          "name": "Docs",
          "domain": "docs.example.com"
        }
        """)
        let client = try APIClient(
            serverURL: "https://api.umami.is",
            serverType: .cloud,
            cloudRegion: .eu,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAPIKey("cloud-key")

        let website = try await client.createWebsiteAsync(
            body: CreateWebsiteRequest(
                name: "Docs",
                domain: "docs.example.com",
                shareId: nil,
                teamId: "team-1",
                id: nil
            )
        )

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(website.id == "created-site")
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://api.umami.is/v1/eu/websites")
        #expect(request.value(forHTTPHeaderField: "x-umami-api-key") == "cloud-key")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)

        let body = try #require(request.bodyData)
        let payload = try JSONDecoder().decode(CreateWebsiteRequest.self, from: body)
        #expect(payload.name == "Docs")
        #expect(payload.domain == "docs.example.com")
        #expect(payload.teamId == "team-1")
    }

    @Test func cloudOfficialV1BaseURLDoesNotDoublePrefixAndInfersRegion() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        {
          "data": [],
          "count": 0,
          "page": 1,
          "pageSize": 50
        }
        """)
        let client = try APIClient(
            serverURL: "https://api.umami.is/v1/us",
            serverType: .cloud,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAPIKey("cloud-key")

        _ = try await client.getWebsitesAsync(page: 1, pageSize: 50, includeTeams: true)

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(request.url?.absoluteString == "https://api.umami.is/v1/us/websites?page=1&pageSize=50&includeTeams=true")
    }

    @Test func cloudRateLimiterSpacesConcurrentRequestsConservatively() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: #"{"data":[],"count":0}"#)
        URLProtocolStub.enqueue(json: #"{"data":[],"count":0}"#)
        let client = try APIClient(
            serverURL: "https://api.umami.is",
            serverType: .cloud,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAPIKey("cloud-key")

        async let first = client.getWebsitesAsync(page: 1, pageSize: 1)
        async let second = client.getWebsitesAsync(page: 1, pageSize: 1)
        _ = try await (first, second)

        let dates = URLProtocolStub.requestDates
        #expect(dates.count == 2)
        if dates.count == 2 {
            #expect(abs(dates[1].timeIntervalSince(dates[0])) >= 0.28)
        }
    }

    @Test func metricsOmitComparisonButKeepFilters() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: "[]")
        let client = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )

        var query = AnalyticsQueryOptions(compare: .previous, filters: [:])
        query.setFilter(.country, value: "US")

        _ = try await client.getWebsiteMetricsAsync(
            id: "site-1",
            dateRange: DateRange(startAt: 10, endAt: 20, unit: "day", timezone: nil),
            type: "browser",
            query: query
        )

        let queryItems = URLProtocolStub.recordedRequests.first?.url?.queryItems ?? [:]
        #expect(queryItems["compare"] == nil)
        #expect(queryItems["country"] == "US")
        #expect(queryItems["type"] == "browser")
    }

    @Test func transportMapsHTTPUnauthorizedRateLimitAndMalformedJSON() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: #"{"message":"Nope"}"#, statusCode: 401)
        let unauthorizedClient = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )

        do {
            _ = try await unauthorizedClient.getWebsitesAsync()
            Issue.record("401 should map to unauthorized")
        } catch let error as APIError {
            #expect(error.message == APIError.unauthorized.message)
        }

        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: #"{"message":"slow down"}"#, statusCode: 429, headers: ["Retry-After": "0"])
        URLProtocolStub.enqueue(json: #"{"message":"still slow"}"#, statusCode: 429, headers: ["Retry-After": httpDate(secondsFromNow: -1)])
        URLProtocolStub.enqueue(json: #"{"data":[],"count":0}"#)
        let retryClient = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )
        _ = try await retryClient.getWebsitesAsync()
        #expect(URLProtocolStub.recordedRequests.count == 3)

        URLProtocolStub.reset()
        URLProtocolStub.enqueue(data: Data("not-json".utf8), statusCode: 200)
        let decodingClient = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )
        do {
            _ = try await decodingClient.getWebsitesAsync()
            Issue.record("Malformed 2xx JSON should map to decodingError")
        } catch let error as APIError {
            #expect(error.message == APIError.decodingError.message)
        }
    }

    @Test func setBaseURLClearsCredentialsBeforeNextRequest() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        {
          "cloudMode": false,
          "privateMode": true,
          "trackerScriptName": "script.js"
        }
        """)
        let client = try APIClient(
            serverURL: "https://old.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAuthToken("old-token")
        try client.setBaseURL("https://new.example.com/base")

        let config = try await client.getServerConfigAsync()

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(config.trackerScriptName == "script.js")
        #expect(request.url?.absoluteString == "https://new.example.com/base/api/config")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func cloudSetBaseURLAdoptsOfficialRegionalV1Path() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: #"{"data":[],"count":0}"#)
        let client = try APIClient(
            serverURL: "https://api.umami.is",
            serverType: .cloud,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAPIKey("old-key")
        try client.setBaseURL("https://api.umami.is/v1/eu")
        client.setAPIKey("new-key")

        _ = try await client.getWebsitesAsync(page: 1, pageSize: 10)

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(request.url?.absoluteString == "https://api.umami.is/v1/eu/websites?page=1&pageSize=10")
        #expect(request.value(forHTTPHeaderField: "x-umami-api-key") == "new-key")
    }

    @Test func cloudSetBaseURLExplicitRegionOverridesExistingRegionAndClearsCredentials() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: #"{"data":[],"count":0}"#)
        let client = try APIClient(
            serverURL: "https://api.umami.is",
            serverType: .cloud,
            cloudRegion: .eu,
            urlSession: URLProtocolStub.makeSession()
        )
        client.setAPIKey("old-key")
        try client.setBaseURL("https://api.umami.is/v1/us")

        _ = try await client.getWebsitesAsync(page: 1, pageSize: 10)

        let request = try #require(URLProtocolStub.recordedRequests.first)
        #expect(request.url?.absoluteString == "https://api.umami.is/v1/us/websites?page=1&pageSize=10")
        #expect(request.value(forHTTPHeaderField: "x-umami-api-key") == nil)
    }

    @Test func eventSeriesAggregatesDuplicateBucketsAndKeepsQueryFilters() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        [
          { "x": "signup", "t": "2025-10-22T00:00:00Z", "y": 2 },
          { "x": "purchase", "t": "2025-10-22T00:00:00Z", "y": "3" },
          { "x": "signup", "t": "2025-10-22T01:00:00Z", "y": 4 }
        ]
        """)
        let client = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )

        var query = AnalyticsQueryOptions()
        query.setFilter(.country, value: "US")

        let series = try await client.getWebsiteEventSeriesAsync(
            id: "site-1",
            dateRange: DateRange(startAt: 10, endAt: 20, unit: "hour", timezone: nil),
            eventName: "signup",
            query: query
        )

        let request = try #require(URLProtocolStub.recordedRequests.first)
        let queryItems = request.url?.queryItems ?? [:]
        #expect(request.url?.path == "/api/websites/site-1/events/series")
        #expect(queryItems["unit"] == "hour")
        #expect(queryItems["event"] == "signup")
        #expect(queryItems["country"] == "US")
        #expect(series.map(\.value) == [5, 4])
        #expect(series[0].date < series[1].date)
    }

    @Test func eventDataEventsDeduplicatePropertyRowsWithoutInflatingCounts() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.enqueue(json: """
        [
          { "eventName": "button-click", "propertyName": "color", "total": 4 },
          { "eventName": "button-click", "propertyName": "size", "total": 4 },
          { "eventName": "signup", "propertyName": "plan", "total": 2 }
        ]
        """)
        let client = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )

        var query = AnalyticsQueryOptions()
        query.setFilter(.country, value: "US")

        let events = try await client.getEventDataEventsAsync(
            id: "site-1",
            dateRange: DateRange(startAt: 10, endAt: 20, unit: "day", timezone: nil),
            event: nil,
            query: query
        )

        let request = try #require(URLProtocolStub.recordedRequests.first)
        let queryItems = request.url?.queryItems ?? [:]
        #expect(request.url?.path == "/api/websites/site-1/event-data/events")
        #expect(queryItems["country"] == "US")
        #expect(events.map { $0.value } == ["button-click", "signup"])
        #expect(events.map { $0.count } == [4, 2])
    }

    @Test func verifyTokenWithoutBearerTokenFailsBeforeNetwork() async throws {
        URLProtocolStub.reset()
        let client = try APIClient(
            serverURL: "https://self.example.com",
            serverType: .selfHosted,
            urlSession: URLProtocolStub.makeSession()
        )

        do {
            _ = try await client.verifyTokenAsync()
            Issue.record("verifyTokenAsync should fail without an auth token")
        } catch let error as APIError {
            #expect(error.message == APIError.unauthorized.message)
        }

        #expect(URLProtocolStub.recordedRequests.isEmpty)
    }
}

private final class URLProtocolStub: URLProtocol {
    private struct StubResponse {
        let statusCode: Int
        let headers: [String: String]
        let data: Data
    }

    private static let lock = NSLock()
    private nonisolated(unsafe) static var responses: [StubResponse] = []
    private nonisolated(unsafe) static var requests: [URLRequest] = []
    private nonisolated(unsafe) static var dates: [Date] = []

    static var recordedRequests: [URLRequest] {
        lock.lock()
        defer { lock.unlock() }
        return requests
    }

    static var requestDates: [Date] {
        lock.lock()
        defer { lock.unlock() }
        return dates
    }

    static func reset() {
        lock.lock()
        responses = []
        requests = []
        dates = []
        lock.unlock()
    }

    static func enqueue(json: String, statusCode: Int = 200, headers: [String: String] = [:]) {
        enqueue(data: Data(json.utf8), statusCode: statusCode, headers: headers)
    }

    static func enqueue(data: Data, statusCode: Int = 200, headers: [String: String] = [:]) {
        let response = StubResponse(
            statusCode: statusCode,
            headers: headers,
            data: data
        )

        lock.lock()
        responses.append(response)
        lock.unlock()
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response: StubResponse
        Self.lock.lock()
        Self.requests.append(request)
        Self.dates.append(Date())
        if Self.responses.isEmpty {
            response = StubResponse(
                statusCode: 500,
                headers: [:],
                data: Data(#"{"message":"Missing stub response"}"#.utf8)
            )
        } else {
            response = Self.responses.removeFirst()
        }
        Self.lock.unlock()

        let httpResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: response.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: response.headers
        )!
        client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}

private func httpDate(secondsFromNow: TimeInterval) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss zzz"
    return formatter.string(from: Date().addingTimeInterval(secondsFromNow))
}

private extension URL {
    var queryItems: [String: String] {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: String]()) { result, item in
                result[item.name] = item.value
            } ?? [:]
    }
}

private extension URLRequest {
    var bodyData: Data? {
        if let httpBody {
            return httpBody
        }

        guard let httpBodyStream else {
            return nil
        }

        httpBodyStream.open()
        defer { httpBodyStream.close() }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1_024)
        while httpBodyStream.hasBytesAvailable {
            let count = httpBodyStream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }

        return data.isEmpty ? nil : data
    }
}
