import Foundation
import Combine
import Testing
@testable import Umami_Analytics

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

private final class StubAPIClient: APIClient {
    private(set) var eventsCallsByWebsite: [String: Int] = [:]

    init() throws {
        try super.init(serverURL: "https://example.com")
    }

    override func getWebsiteEvents(
        id: String,
        dateRange: DateRange,
        page: Int,
        pageSize: Int,
        search: String?
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
