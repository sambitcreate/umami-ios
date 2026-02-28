import Foundation
import Combine
import Testing
@testable import Umami_Analytics

@MainActor
struct WebsiteViewModelTests {

    @Test func tabLazyLoadingFetchesOncePerTabUnlessForcedRefresh() async {
        let service = MockWebsiteService()
        let viewModel = WebsiteViewModel(
            service: service,
            shouldStartBackgroundRefresh: false,
            config: testConfig(realtimePollInterval: 60)
        )

        viewModel.selectWebsite(makeWebsite(id: "site-1"))
        await pause()

        viewModel.selectDetailTab(.sessions)
        await pause()

        #expect(service.sessionStatsCalls == 1)
        #expect(service.sessionsWeeklyCalls == 1)

        viewModel.selectDetailTab(.overview)
        await pause()
        viewModel.selectDetailTab(.sessions)
        await pause()

        #expect(service.sessionStatsCalls == 1)
        #expect(service.sessionsWeeklyCalls == 1)

        viewModel.refreshCurrentTab()
        await pause()

        #expect(service.sessionStatsCalls == 2)
        #expect(service.sessionsWeeklyCalls == 2)
    }

    @Test func eventsPaginationResetsAndLoadsMoreCorrectly() async {
        let service = MockWebsiteService()
        service.eventsPageProvider = { page, pageSize, search in
            let count = 3
            if page == 1 {
                return PaginatedResponse(
                    data: [
                        makeRecord(id: "event-1", title: search ?? "signup", count: 2),
                        makeRecord(id: "event-2", title: search ?? "purchase", count: 1)
                    ],
                    count: count,
                    page: page,
                    pageSize: pageSize
                )
            }

            return PaginatedResponse(
                data: [makeRecord(id: "event-3", title: search ?? "checkout", count: 1)],
                count: count,
                page: page,
                pageSize: pageSize
            )
        }

        let viewModel = WebsiteViewModel(
            service: service,
            shouldStartBackgroundRefresh: false,
            config: testConfig(realtimePollInterval: 60)
        )

        viewModel.selectWebsite(makeWebsite(id: "site-1"))
        await pause()

        viewModel.selectDetailTab(.events)
        await pause()

        #expect(service.eventRequests.map(\.page) == [1])
        #expect(viewModel.eventsPage?.data.count == 2)
        #expect(viewModel.hasMoreEvents == true)

        viewModel.loadMoreEvents()
        await pause()

        #expect(service.eventRequests.map(\.page) == [1, 2])
        #expect(viewModel.eventsPage?.data.count == 3)
        #expect(viewModel.hasMoreEvents == false)

        viewModel.applyEventsSearch("signup")
        await pause()

        #expect(service.eventRequests.last?.page == 1)
        #expect(service.eventRequests.last?.search == "signup")
        #expect(viewModel.eventsPage?.data.count == 2)
    }

    @Test func sessionsPaginationResetsAndLoadsMoreCorrectly() async {
        let service = MockWebsiteService()
        service.sessionsPageProvider = { page, pageSize, search in
            let count = 3
            if page == 1 {
                return PaginatedResponse(
                    data: [
                        makeRecord(id: "session-1", title: search ?? "abc", count: 2),
                        makeRecord(id: "session-2", title: search ?? "def", count: 1)
                    ],
                    count: count,
                    page: page,
                    pageSize: pageSize
                )
            }

            return PaginatedResponse(
                data: [makeRecord(id: "session-3", title: search ?? "ghi", count: 1)],
                count: count,
                page: page,
                pageSize: pageSize
            )
        }

        let viewModel = WebsiteViewModel(
            service: service,
            shouldStartBackgroundRefresh: false,
            config: testConfig(realtimePollInterval: 60)
        )

        viewModel.selectWebsite(makeWebsite(id: "site-1"))
        await pause()

        viewModel.selectDetailTab(.sessions)
        await pause()

        #expect(service.sessionRequests.map(\.page) == [1])
        #expect(viewModel.sessionsPage?.data.count == 2)
        #expect(viewModel.hasMoreSessions == true)

        viewModel.loadMoreSessions()
        await pause()

        #expect(service.sessionRequests.map(\.page) == [1, 2])
        #expect(viewModel.sessionsPage?.data.count == 3)
        #expect(viewModel.hasMoreSessions == false)

        viewModel.applySessionsSearch("abc")
        await pause()

        #expect(service.sessionRequests.last?.page == 1)
        #expect(service.sessionRequests.last?.search == "abc")
        #expect(viewModel.sessionsPage?.data.count == 2)
    }

    @Test func realtimePollingStartsAndStopsAcrossTabLifecycle() async {
        let service = MockWebsiteService()
        let viewModel = WebsiteViewModel(
            service: service,
            shouldStartBackgroundRefresh: false,
            config: testConfig(realtimePollInterval: 0.05)
        )

        viewModel.selectWebsite(makeWebsite(id: "site-1"))
        await pause(0.06)

        let initialCalls = service.realtimeSnapshotCalls

        viewModel.selectDetailTab(.realtime)
        await pause(0.18)

        let callsWhileActive = service.realtimeSnapshotCalls
        #expect(callsWhileActive >= initialCalls + 2)

        viewModel.selectDetailTab(.overview)
        let callsAfterExit = service.realtimeSnapshotCalls
        await pause(0.18)

        #expect(service.realtimeSnapshotCalls == callsAfterExit)

        viewModel.selectDetailTab(.realtime)
        await pause(0.12)
        #expect(service.realtimeSnapshotCalls > callsAfterExit)

        viewModel.handleDetailDisappear()
        let callsAfterDisappear = service.realtimeSnapshotCalls
        await pause(0.18)

        #expect(service.realtimeSnapshotCalls == callsAfterDisappear)
        #expect(service.stopRealtimeUpdatesCalls.contains("site-1"))
    }
}

@MainActor
private final class MockWebsiteService: WebsiteServicing {
    struct PageRequest: Equatable {
        let id: String
        let page: Int
        let pageSize: Int
        let search: String?
    }

    var eventRequests: [PageRequest] = []
    var sessionRequests: [PageRequest] = []

    var sessionStatsCalls = 0
    var sessionsWeeklyCalls = 0
    var realtimeSnapshotCalls = 0
    var stopRealtimeUpdatesCalls: [String] = []

    var eventsPageProvider: (Int, Int, String?) -> PaginatedResponse<AnalyticsRecord> = { page, pageSize, _ in
        PaginatedResponse(
            data: [makeRecord(id: "event-\(page)", title: "event", count: 1)],
            count: 1,
            page: page,
            pageSize: pageSize
        )
    }

    var sessionsPageProvider: (Int, Int, String?) -> PaginatedResponse<AnalyticsRecord> = { page, pageSize, _ in
        PaginatedResponse(
            data: [makeRecord(id: "session-\(page)", title: "session", count: 1)],
            count: 1,
            page: page,
            pageSize: pageSize
        )
    }

    func createWebsite(name: String, domain: String, shareId: String?, teamId: String?, id: String?) -> AnyPublisher<WebsiteModel, Error> {
        Just(makeWebsite(id: id ?? "created-site", name: name, domain: domain))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateWebsite(id: String, name: String?, domain: String?, shareId: String?) -> AnyPublisher<WebsiteModel, Error> {
        Just(makeWebsite(id: id, name: name ?? "Updated", domain: domain ?? "updated.dev"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteWebsite(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        Just([makeWebsite(id: "site-1")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteStats(id: String, period: StatsPeriod) -> AnyPublisher<WebsiteStatsResponse, Error> {
        Just(WebsiteStatsResponse(pageviews: 10, visitors: 5, visits: 6, bounces: 2, totaltime: 120))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteMetrics(id: String, period: StatsPeriod, type: String) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        Just([MetricItem(x: type, y: 4)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsitePageviews(id: String, period: StatsPeriod) -> AnyPublisher<PageviewsResponse, Error> {
        let point = TimeSeriesData(date: Date(timeIntervalSince1970: 1_700_000_000), value: 2)
        let response = PageviewsResponse(pageviews: [point], sessions: [point])
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchActiveUsers(id: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        Just(ActiveUsersResponse(visitors: 2))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchRealtimeSnapshot(websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        realtimeSnapshotCalls += 1
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

    func fetchWebsiteEventSeries(id: String, period: StatsPeriod, eventName: String?) -> AnyPublisher<[TimeSeriesData], Error> {
        Just([TimeSeriesData(date: Date(timeIntervalSince1970: 1_700_000_000), value: 1)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteEvents(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        eventRequests.append(PageRequest(id: id, page: page, pageSize: pageSize, search: search))
        return Just(eventsPageProvider(page, pageSize, search))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEventDataFields(id: String, period: StatsPeriod) -> AnyPublisher<[FilterValue], Error> {
        Just([FilterValue(value: "event")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEventDataProperties(id: String, period: StatsPeriod, propertyName: String?) -> AnyPublisher<[FilterValue], Error> {
        Just([FilterValue(value: propertyName ?? "prop")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEventDataEvents(id: String, period: StatsPeriod, event: String?) -> AnyPublisher<[FilterValue], Error> {
        Just([FilterValue(value: event ?? "signup")])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEventDataStats(id: String, period: StatsPeriod) -> AnyPublisher<[String: MetricValue], Error> {
        Just(["events": MetricValue(value: 3, prev: 2)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchEventDataValues(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) -> AnyPublisher<[FilterValue], Error> {
        Just([FilterValue(value: eventName ?? propertyName ?? "value", count: 1)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionStats(id: String, period: StatsPeriod) -> AnyPublisher<[String: MetricValue], Error> {
        sessionStatsCalls += 1
        return Just(["sessions": MetricValue(value: 5, prev: 4)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionsWeekly(id: String, period: StatsPeriod) -> AnyPublisher<[WeeklySessionPoint], Error> {
        sessionsWeeklyCalls += 1
        return Just([WeeklySessionPoint(date: Date(timeIntervalSince1970: 1_700_000_000), value: 5)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessions(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        sessionRequests.append(PageRequest(id: id, page: page, pageSize: pageSize, search: search))
        return Just(sessionsPageProvider(page, pageSize, search))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error> {
        Just(makeRecord(id: sessionId, title: "session", count: 1))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionActivity(id: String, sessionId: String, period: StatsPeriod) -> AnyPublisher<[AnalyticsRecord], Error> {
        Just([makeRecord(id: "activity-\(sessionId)", title: "activity", count: 1)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionProperties(id: String, sessionId: String) -> AnyPublisher<[String: JSONValue], Error> {
        Just(["sessionId": .string(sessionId)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func invalidateAnalyticsCache(for websiteId: String?) {
    }

    func startRealtimeUpdates(for websiteId: String, interval: TimeInterval, completion: @escaping (Int) -> Void) {
        completion(2)
    }

    func stopRealtimeUpdates(for websiteId: String) {
        stopRealtimeUpdatesCalls.append(websiteId)
    }

    func fetchCachedWebsites() -> [UmamiWebsite] {
        []
    }

    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats? {
        nil
    }

    // MARK: - Async Mock Implementations

    func fetchWebsitesAsync() async throws -> [WebsiteModel] { [makeWebsite(id: "site-1")] }
    func fetchWebsiteStatsAsync(id: String, period: StatsPeriod) async throws -> WebsiteStatsResponse {
        WebsiteStatsResponse(pageviews: 10, visitors: 5, visits: 6, bounces: 2, totaltime: 120)
    }
    func fetchWebsiteMetricsAsync(id: String, period: StatsPeriod, type: String) async throws -> WebsiteMetricsResponse { [MetricItem(x: type, y: 4)] }
    func fetchWebsitePageviewsAsync(id: String, period: StatsPeriod) async throws -> PageviewsResponse {
        let point = TimeSeriesData(date: Date(timeIntervalSince1970: 1_700_000_000), value: 2)
        return PageviewsResponse(pageviews: [point], sessions: [point])
    }
    func fetchActiveUsersAsync(id: String) async throws -> ActiveUsersResponse { ActiveUsersResponse(visitors: 2) }
    func fetchRealtimeSnapshotAsync(websiteId: String) async throws -> RealtimeData {
        realtimeSnapshotCalls += 1
        return RealtimeData(websiteId: websiteId, timestamp: 1_700_000_000_000, pageviews: [], sessions: 2, events: [], countries: ["US": 2])
    }
    func fetchWebsiteEventSeriesAsync(id: String, period: StatsPeriod, eventName: String?) async throws -> [TimeSeriesData] {
        [TimeSeriesData(date: Date(timeIntervalSince1970: 1_700_000_000), value: 1)]
    }
    func fetchWebsiteEventsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) async throws -> PaginatedResponse<AnalyticsRecord> {
        eventRequests.append(PageRequest(id: id, page: page, pageSize: pageSize, search: search))
        return eventsPageProvider(page, pageSize, search)
    }
    func fetchEventDataFieldsAsync(id: String, period: StatsPeriod) async throws -> [FilterValue] { [FilterValue(value: "event")] }
    func fetchEventDataPropertiesAsync(id: String, period: StatsPeriod, propertyName: String?) async throws -> [FilterValue] { [FilterValue(value: propertyName ?? "prop")] }
    func fetchEventDataEventsAsync(id: String, period: StatsPeriod, event: String?) async throws -> [FilterValue] { [FilterValue(value: event ?? "signup")] }
    func fetchEventDataStatsAsync(id: String, period: StatsPeriod) async throws -> [String: MetricValue] { ["events": MetricValue(value: 3, prev: 2)] }
    func fetchEventDataValuesAsync(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) async throws -> [FilterValue] {
        [FilterValue(value: eventName ?? propertyName ?? "value", count: 1)]
    }
    func fetchWebsiteSessionStatsAsync(id: String, period: StatsPeriod) async throws -> [String: MetricValue] {
        sessionStatsCalls += 1
        return ["sessions": MetricValue(value: 5, prev: 4)]
    }
    func fetchWebsiteSessionsWeeklyAsync(id: String, period: StatsPeriod) async throws -> [WeeklySessionPoint] {
        sessionsWeeklyCalls += 1
        return [WeeklySessionPoint(date: Date(timeIntervalSince1970: 1_700_000_000), value: 5)]
    }
    func fetchWebsiteSessionsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) async throws -> PaginatedResponse<AnalyticsRecord> {
        sessionRequests.append(PageRequest(id: id, page: page, pageSize: pageSize, search: search))
        return sessionsPageProvider(page, pageSize, search)
    }
    func fetchWebsiteSessionAsync(id: String, sessionId: String) async throws -> AnalyticsRecord { makeRecord(id: sessionId, title: "session", count: 1) }
    func fetchWebsiteSessionActivityAsync(id: String, sessionId: String, period: StatsPeriod) async throws -> [AnalyticsRecord] {
        [makeRecord(id: "activity-\(sessionId)", title: "activity", count: 1)]
    }
    func fetchWebsiteSessionPropertiesAsync(id: String, sessionId: String) async throws -> [String: JSONValue] { ["sessionId": .string(sessionId)] }
    func createWebsiteAsync(name: String, domain: String, shareId: String?, teamId: String?, id: String?) async throws -> WebsiteModel {
        makeWebsite(id: id ?? "created-site", name: name, domain: domain)
    }
    func updateWebsiteAsync(id: String, name: String?, domain: String?, shareId: String?) async throws -> WebsiteModel {
        makeWebsite(id: id, name: name ?? "Updated", domain: domain ?? "updated.dev")
    }
    func deleteWebsiteAsync(id: String) async throws {}
    func startRealtimeUpdatesAsync(for websiteId: String, interval: TimeInterval) -> AsyncStream<Int> {
        AsyncStream { $0.yield(2); $0.finish() }
    }
}

private func makeWebsite(id: String, name: String = "Test Site", domain: String = "example.com") -> WebsiteModel {
    WebsiteModel(id: id, name: name, domain: domain)
}

private func makeRecord(id: String, title: String, count: Int) -> AnalyticsRecord {
    let json = """
    {
      "id": "\(id)",
      "eventName": "\(title)",
      "sessionId": "\(id)",
      "count": \(count),
      "timestamp": 1700000000000
    }
    """.data(using: .utf8)!

    return try! JSONDecoder().decode(AnalyticsRecord.self, from: json)
}

private func testConfig(realtimePollInterval: TimeInterval) -> AnalyticsRuntimeConfig {
    AnalyticsRuntimeConfig(
        dashboardRefreshInterval: 3600,
        eventsSessionsPageSize: 2,
        analyticsCacheTTL: 60,
        realtimePollInterval: realtimePollInterval
    )
}

private func pause(_ seconds: TimeInterval = 0.08) async {
    try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
}
