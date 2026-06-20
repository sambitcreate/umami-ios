import Foundation
import Combine
import Testing
@testable import Umami_Analytics

@MainActor
struct WebsiteServiceTests {

    @Test func cacheUsesTTLAndRefetchesAfterExpiry() async throws {
        let clock = MutableClock(now: Date(timeIntervalSince1970: 1_700_000_000))
        let apiClient = try StubAPIClient()
        let service = WebsiteService(
            apiClientProvider: { apiClient },
            nowProvider: { clock.now },
            analyticsCacheTTL: 60
        )

        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        #expect(apiClient.eventsCallsByWebsite["site-1"] == 1)

        clock.advance(by: 30)
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        #expect(apiClient.eventsCallsByWebsite["site-1"] == 1)

        clock.advance(by: 31)
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        #expect(apiClient.eventsCallsByWebsite["site-1"] == 2)
    }

    @Test func targetedInvalidationClearsOnlyMatchingWebsiteKeys() async throws {
        let clock = MutableClock(now: Date(timeIntervalSince1970: 1_700_100_000))
        let apiClient = try StubAPIClient()
        let service = WebsiteService(
            apiClientProvider: { apiClient },
            nowProvider: { clock.now },
            analyticsCacheTTL: 120
        )

        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-2", period: .day, page: 1, pageSize: 20, search: nil)
        )

        _ = try await awaitPublisher(service.fetchRealtimeSnapshot(websiteId: "site-1"))
        _ = try await awaitPublisher(service.fetchRealtimeSnapshot(websiteId: "site-2"))

        #expect(apiClient.eventsCallsByWebsite["site-1"] == 1)
        #expect(apiClient.eventsCallsByWebsite["site-2"] == 1)
        #expect(service.latestRealtimeSnapshot(for: "site-1") != nil)
        #expect(service.latestRealtimeSnapshot(for: "site-2") != nil)

        service.invalidateAnalyticsCache(for: "site-1")

        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-2", period: .day, page: 1, pageSize: 20, search: nil)
        )

        #expect(apiClient.eventsCallsByWebsite["site-1"] == 2)
        #expect(apiClient.eventsCallsByWebsite["site-2"] == 1)
        #expect(service.latestRealtimeSnapshot(for: "site-1") == nil)
        #expect(service.latestRealtimeSnapshot(for: "site-2") != nil)
    }

    @Test func globalInvalidationClearsAllAnalyticsAndRealtimeCaches() async throws {
        let clock = MutableClock(now: Date(timeIntervalSince1970: 1_700_200_000))
        let apiClient = try StubAPIClient()
        let service = WebsiteService(
            apiClientProvider: { apiClient },
            nowProvider: { clock.now },
            analyticsCacheTTL: 120
        )

        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-2", period: .day, page: 1, pageSize: 20, search: nil)
        )

        _ = try await awaitPublisher(service.fetchRealtimeSnapshot(websiteId: "site-1"))
        _ = try await awaitPublisher(service.fetchRealtimeSnapshot(websiteId: "site-2"))

        service.invalidateAnalyticsCache(for: nil)

        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-1", period: .day, page: 1, pageSize: 20, search: nil)
        )
        _ = try await awaitPublisher(
            service.fetchWebsiteEvents(id: "site-2", period: .day, page: 1, pageSize: 20, search: nil)
        )

        #expect(apiClient.eventsCallsByWebsite["site-1"] == 2)
        #expect(apiClient.eventsCallsByWebsite["site-2"] == 2)
        #expect(service.latestRealtimeSnapshot(for: "site-1") == nil)
        #expect(service.latestRealtimeSnapshot(for: "site-2") == nil)
    }

    @Test func concurrentAsyncFetchesShareOneInFlightRequest() async throws {
        let apiClient = try StubAPIClient()
        apiClient.statsDelayNanoseconds = 50_000_000
        let service = WebsiteService(
            apiClientProvider: { apiClient },
            nowProvider: { Date(timeIntervalSince1970: 1_700_300_000) },
            analyticsCacheTTL: 120
        )

        async let first = service.fetchWebsiteStatsAsync(id: "site-1", period: .day)
        async let second = service.fetchWebsiteStatsAsync(id: "site-1", period: .day)
        let (firstStats, secondStats) = try await (first, second)

        #expect(firstStats.pageviews == 101)
        #expect(secondStats.pageviews == 101)
        #expect(apiClient.statsCallsByWebsite["site-1"] == 1)
    }

    @Test func asyncCacheSeparatesDifferentQueryOptions() async throws {
        let apiClient = try StubAPIClient()
        let service = WebsiteService(
            apiClientProvider: { apiClient },
            nowProvider: { Date(timeIntervalSince1970: 1_700_400_000) },
            analyticsCacheTTL: 120
        )

        var usQuery = AnalyticsQueryOptions()
        usQuery.setFilter(.country, value: "US")

        var indiaQuery = AnalyticsQueryOptions()
        indiaQuery.setFilter(.country, value: "IN")

        _ = try await service.fetchWebsiteStatsAsync(id: "site-1", period: .day, query: usQuery)
        _ = try await service.fetchWebsiteStatsAsync(id: "site-1", period: .day, query: usQuery)
        _ = try await service.fetchWebsiteStatsAsync(id: "site-1", period: .day, query: indiaQuery)

        #expect(apiClient.statsCallsByWebsite["site-1"] == 2)
        #expect(apiClient.statsQueries.map(\.filters[.country]) == ["US", "IN"])
    }

    @Test func unauthorizedServiceWithoutAPIClientFailsPublisherAndAsyncPaths() async throws {
        let service = WebsiteService(apiClientProvider: { nil })

        do {
            _ = try await awaitPublisher(service.fetchWebsiteMetrics(id: "site-1", period: .day, type: "path"))
            Issue.record("publisher path should fail without an API client")
        } catch let error as APIError {
            #expect(error.message == APIError.unauthorized.message)
        }

        do {
            _ = try await service.fetchWebsiteStatsAsync(id: "site-1", period: .day)
            Issue.record("async path should fail without an API client")
        } catch let error as APIError {
            #expect(error.message == APIError.unauthorized.message)
        }
    }
}

private final class MutableClock {
    private(set) var now: Date

    init(now: Date) {
        self.now = now
    }

    func advance(by seconds: TimeInterval) {
        now = now.addingTimeInterval(seconds)
    }
}

private final class StubAPIClient: APIClient, @unchecked Sendable {
    private(set) var eventsCallsByWebsite: [String: Int] = [:]
    private(set) var statsCallsByWebsite: [String: Int] = [:]
    private(set) var statsQueries: [AnalyticsQueryOptions] = []
    var statsDelayNanoseconds: UInt64 = 0

    init() throws {
        try super.init(serverURL: "https://example.com")
    }

    override func getWebsiteStatsAsync(
        id: String,
        dateRange: DateRange,
        query: AnalyticsQueryOptions = .default
    ) async throws -> WebsiteStatsResponse {
        statsCallsByWebsite[id, default: 0] += 1
        statsQueries.append(query)
        if statsDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: statsDelayNanoseconds)
        }
        let callCount = statsCallsByWebsite[id] ?? 0
        return WebsiteStatsResponse(
            pageviews: 100 + callCount,
            visitors: 40,
            visits: 50,
            bounces: 5,
            totaltime: 900
        )
    }

    override func getWebsiteEvents(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        eventsCallsByWebsite[id, default: 0] += 1
        let eventName = search ?? "event-\(page)"
        let response = PaginatedResponse(
            data: [makeRecord(id: "\(id)-\(page)", eventName: eventName, count: page)],
            count: 1,
            page: page,
            pageSize: pageSize
        )
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    override func getRealtime(websiteId: String, timezone: String?) -> AnyPublisher<RealtimeData, Error> {
        let snapshot = RealtimeData(
            websiteId: websiteId,
            timestamp: 1_700_000_000_000,
            pageviews: [],
            sessions: 2,
            events: [],
            countries: ["US": 2]
        )
        return Just(snapshot)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func makeRecord(id: String, eventName: String, count: Int) -> AnalyticsRecord {
        let json = """
        {
          "id": "\(id)",
          "eventName": "\(eventName)",
          "count": \(count),
          "timestamp": 1700000000000
        }
        """.data(using: .utf8)!

        return try! JSONDecoder().decode(AnalyticsRecord.self, from: json)
    }
}

private func awaitPublisher<T>(_ publisher: AnyPublisher<T, Error>) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
        var didResume = false
        var cancellable: AnyCancellable?

        cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion, !didResume {
                    didResume = true
                    continuation.resume(throwing: error)
                }
                cancellable?.cancel()
                cancellable = nil
            },
            receiveValue: { value in
                if !didResume {
                    didResume = true
                    continuation.resume(returning: value)
                }
            }
        )
    }
}
