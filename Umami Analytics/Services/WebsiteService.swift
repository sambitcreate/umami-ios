//
//  WebsiteService.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import CoreData
import OSLog

@MainActor
protocol WebsiteServicing {
    func createWebsite(name: String, domain: String, shareId: String?, teamId: String?, id: String?) -> AnyPublisher<WebsiteModel, Error>
    func updateWebsite(id: String, name: String?, domain: String?, shareId: String?) -> AnyPublisher<WebsiteModel, Error>
    func deleteWebsite(id: String) -> AnyPublisher<Void, Error>

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error>
    func fetchWebsiteStats(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) -> AnyPublisher<WebsiteStatsResponse, Error>
    func fetchWebsiteMetrics(id: String, period: StatsPeriod, type: String, query: AnalyticsQueryOptions) -> AnyPublisher<WebsiteMetricsResponse, Error>
    func fetchWebsitePageviews(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) -> AnyPublisher<PageviewsResponse, Error>
    func fetchActiveUsers(id: String) -> AnyPublisher<ActiveUsersResponse, Error>
    func fetchRealtimeSnapshot(websiteId: String) -> AnyPublisher<RealtimeData, Error>
    func fetchWebsiteEventSeries(id: String, period: StatsPeriod, eventName: String?, query: AnalyticsQueryOptions) -> AnyPublisher<[TimeSeriesData], Error>
    func fetchWebsiteEvents(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error>
    func fetchWebsiteValues(id: String, type: String, period: StatsPeriod, search: String?, query: AnalyticsQueryOptions) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataFields(id: String, period: StatsPeriod) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataProperties(id: String, period: StatsPeriod, propertyName: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataEvents(id: String, period: StatsPeriod, event: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataStats(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) -> AnyPublisher<[String: MetricValue], Error>
    func fetchEventDataValues(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchWebsiteSessionStats(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) -> AnyPublisher<[String: MetricValue], Error>
    func fetchWebsiteSessionsWeekly(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) -> AnyPublisher<[WeeklySessionPoint], Error>
    func fetchWebsiteSessions(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error>
    func fetchWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error>
    func fetchWebsiteSessionActivity(id: String, sessionId: String, period: StatsPeriod) -> AnyPublisher<[AnalyticsRecord], Error>
    func fetchWebsiteSessionProperties(id: String, sessionId: String) -> AnyPublisher<[String: JSONValue], Error>
    func fetchWebsiteReports(websiteId: String) -> AnyPublisher<[SavedReport], Error>
    func fetchWebsiteSegments(websiteId: String, type: SegmentType?) -> AnyPublisher<[SegmentDefinition], Error>
    func fetchLinks(teamId: String?) -> AnyPublisher<[TrackedAsset], Error>
    func fetchPixels(teamId: String?) -> AnyPublisher<[TrackedAsset], Error>
    func resetWebsite(id: String) -> AnyPublisher<Void, Error>
    func transferWebsite(id: String, userId: String?, teamId: String?) -> AnyPublisher<Void, Error>

    func invalidateAnalyticsCache(for websiteId: String?)
    func startRealtimeUpdates(for websiteId: String, interval: TimeInterval, completion: @escaping (Int) -> Void)
    func stopRealtimeUpdates(for websiteId: String)

    func fetchCachedWebsites() -> [UmamiWebsite]
    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats?
    func purgeExpiredCoreDataStats()

    // MARK: - Async/Await Methods

    func fetchWebsitesAsync() async throws -> [WebsiteModel]
    func fetchWebsiteStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) async throws -> WebsiteStatsResponse
    func fetchWebsiteMetricsAsync(id: String, period: StatsPeriod, type: String, query: AnalyticsQueryOptions) async throws -> WebsiteMetricsResponse
    func fetchWebsitePageviewsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) async throws -> PageviewsResponse
    func fetchActiveUsersAsync(id: String) async throws -> ActiveUsersResponse
    func fetchRealtimeSnapshotAsync(websiteId: String) async throws -> RealtimeData
    func fetchWebsiteEventSeriesAsync(id: String, period: StatsPeriod, eventName: String?, query: AnalyticsQueryOptions) async throws -> [TimeSeriesData]
    func fetchWebsiteEventsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions) async throws -> PaginatedResponse<AnalyticsRecord>
    func fetchWebsiteValuesAsync(id: String, type: String, period: StatsPeriod, search: String?, query: AnalyticsQueryOptions) async throws -> [FilterValue]
    func fetchEventDataFieldsAsync(id: String, period: StatsPeriod) async throws -> [FilterValue]
    func fetchEventDataPropertiesAsync(id: String, period: StatsPeriod, propertyName: String?) async throws -> [FilterValue]
    func fetchEventDataEventsAsync(id: String, period: StatsPeriod, event: String?) async throws -> [FilterValue]
    func fetchEventDataStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) async throws -> [String: MetricValue]
    func fetchEventDataValuesAsync(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) async throws -> [FilterValue]
    func fetchWebsiteSessionStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) async throws -> [String: MetricValue]
    func fetchWebsiteSessionsWeeklyAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions) async throws -> [WeeklySessionPoint]
    func fetchWebsiteSessionsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions) async throws -> PaginatedResponse<AnalyticsRecord>
    func fetchWebsiteSessionAsync(id: String, sessionId: String) async throws -> AnalyticsRecord
    func fetchWebsiteSessionActivityAsync(id: String, sessionId: String, period: StatsPeriod) async throws -> [AnalyticsRecord]
    func fetchWebsiteSessionPropertiesAsync(id: String, sessionId: String) async throws -> [String: JSONValue]
    func fetchWebsiteReportsAsync(websiteId: String) async throws -> [SavedReport]
    func fetchWebsiteSegmentsAsync(websiteId: String, type: SegmentType?) async throws -> [SegmentDefinition]
    func fetchLinksAsync(teamId: String?) async throws -> [TrackedAsset]
    func fetchPixelsAsync(teamId: String?) async throws -> [TrackedAsset]
    func createWebsiteAsync(name: String, domain: String, shareId: String?, teamId: String?, id: String?) async throws -> WebsiteModel
    func updateWebsiteAsync(id: String, name: String?, domain: String?, shareId: String?) async throws -> WebsiteModel
    func deleteWebsiteAsync(id: String) async throws
    func resetWebsiteAsync(id: String) async throws
    func transferWebsiteAsync(id: String, userId: String?, teamId: String?) async throws
    func startRealtimeUpdatesAsync(for websiteId: String, interval: TimeInterval) -> AsyncStream<Int>
}

@MainActor
final class WebsiteService: WebsiteServicing {
    static let shared = WebsiteService()

    private var realtimeTasks: [String: Task<Void, Never>] = [:]
    private let apiClientProvider: @MainActor () -> APIClient?
    private let nowProvider: () -> Date
    private let analyticsCacheTTL: TimeInterval
    private let analyticsCacheMaxEntries: Int
    private let coreDataStatsTTL: TimeInterval
    private let realtimeSnapshotTTL: TimeInterval
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "UmamiAnalytics", category: "WebsiteService")

    private struct CacheEntry {
        let expiryDate: Date
        let value: Any
        var lastAccessDate: Date
    }

    private struct InFlightValue: @unchecked Sendable {
        let value: Any
    }

    private struct InFlightEntry {
        let task: Task<InFlightValue, Error>
        var waiterIDs: Set<UUID>
    }

    private final class InFlightWaiter: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<InFlightValue, Error>?
        private var observerTask: Task<Void, Never>?
        private var terminalResult: Result<InFlightValue, Error>?
        private var isObserverCancelled = false

        func setContinuation(_ continuation: CheckedContinuation<InFlightValue, Error>) {
            lock.lock()
            let terminalResult = terminalResult
            if terminalResult == nil {
                self.continuation = continuation
            }
            lock.unlock()

            if let terminalResult {
                switch terminalResult {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        func setObserverTask(_ task: Task<Void, Never>) {
            lock.lock()
            let shouldCancel = isObserverCancelled || terminalResult != nil
            if !shouldCancel {
                observerTask = task
            }
            lock.unlock()

            if shouldCancel {
                task.cancel()
            }
        }

        func resume(returning value: InFlightValue) {
            resume(with: .success(value))
        }

        func resume(throwing error: Error) {
            resume(with: .failure(error))
        }

        func cancelObserver() {
            lock.lock()
            isObserverCancelled = true
            let task = observerTask
            observerTask = nil
            lock.unlock()
            task?.cancel()
        }

        private func resume(with result: Result<InFlightValue, Error>) {
            lock.lock()
            guard terminalResult == nil else {
                lock.unlock()
                return
            }
            terminalResult = result
            isObserverCancelled = true
            let continuation = continuation
            self.continuation = nil
            let task = observerTask
            observerTask = nil
            lock.unlock()

            task?.cancel()

            switch result {
            case .success(let value):
                continuation?.resume(returning: value)
            case .failure(let error):
                continuation?.resume(throwing: error)
            }
        }
    }

    private var analyticsCache: [String: CacheEntry] = [:]
    private var realtimeSnapshots: [String: CacheEntry] = [:]
    private var inFlightTasks: [String: InFlightEntry] = [:]

    init(
        apiClientProvider: @escaping @MainActor () -> APIClient? = { AuthManager.shared.apiClient },
        nowProvider: @escaping () -> Date = Date.init,
        analyticsCacheTTL: TimeInterval = AnalyticsRuntimeConfig.default.analyticsCacheTTL,
        analyticsCacheMaxEntries: Int = AnalyticsRuntimeConfig.default.analyticsCacheMaxEntries,
        coreDataStatsTTL: TimeInterval = AnalyticsRuntimeConfig.default.coreDataStatsTTL
    ) {
        self.apiClientProvider = apiClientProvider
        self.nowProvider = nowProvider
        self.analyticsCacheTTL = analyticsCacheTTL
        self.analyticsCacheMaxEntries = analyticsCacheMaxEntries
        self.coreDataStatsTTL = coreDataStatsTTL
        self.realtimeSnapshotTTL = AnalyticsRuntimeConfig.default.realtimeSnapshotTTL
    }

    // MARK: - Website Management

    func createWebsite(name: String, domain: String, shareId: String?, teamId: String?, id: String? = nil) -> AnyPublisher<WebsiteModel, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let payload = CreateWebsiteRequest(name: name, domain: domain, shareId: shareId, teamId: teamId, id: id)

        return apiClient.createWebsite(body: payload)
            .handleEvents(receiveOutput: { [weak self] website in
                self?.saveWebsitesToCoreData([website])
            })
            .eraseToAnyPublisher()
    }

    func updateWebsite(id: String, name: String?, domain: String?, shareId: String?) -> AnyPublisher<WebsiteModel, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let payload = UpdateWebsiteRequest(name: name, domain: domain, shareId: shareId)

        return apiClient.updateWebsite(id: id, body: payload)
            .handleEvents(receiveOutput: { [weak self] website in
                self?.saveWebsitesToCoreData([website])
            })
            .eraseToAnyPublisher()
    }

    func deleteWebsite(id: String) -> AnyPublisher<Void, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.deleteWebsite(id: id)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .finished = completion {
                    self?.deleteWebsiteFromCoreData(id)
                    self?.invalidateAnalyticsCache(for: id)
                }
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website List

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        if let session = AuthManager.shared.currentSession,
           session.serverType == .publicShare,
           let websiteId = session.sharedWebsiteId {
            return apiClient.getWebsite(id: websiteId)
                .map { [$0] }
                .eraseToAnyPublisher()
        }

        return apiClient.getAllAccessibleWebsites()
            .handleEvents(receiveOutput: { [weak self] websites in
                self?.saveWebsitesToCoreData(websites)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Details

    func fetchWebsiteDetails(id: String) -> AnyPublisher<WebsiteModel, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsite(id: id)
            .eraseToAnyPublisher()
    }

    // MARK: - Website Stats

    func fetchWebsiteStats(id: String, period: StatsPeriod = .day, query: AnalyticsQueryOptions = .default) -> AnyPublisher<WebsiteStatsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteStats(id: id, dateRange: dateRange, query: query)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveStatsToCache(websiteId: id, stats: response, period: period)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Metrics

    func fetchWebsiteMetrics(id: String, period: StatsPeriod = .day, type: String = "path", query: AnalyticsQueryOptions = .default) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "metrics", websiteId: id, period: period, extras: [type, query.cacheKey])
        if let cached: WebsiteMetricsResponse = cachedValue(for: cacheKey) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteMetrics(id: id, dateRange: dateRange, type: type, query: query)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveMetricsToCache(websiteId: id, metrics: response, period: period)
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Pageviews

    func fetchWebsitePageviews(id: String, period: StatsPeriod = .day, query: AnalyticsQueryOptions = .default) -> AnyPublisher<PageviewsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsitePageviews(id: id, dateRange: dateRange, query: query)
            .eraseToAnyPublisher()
    }

    // MARK: - Active Users

    func fetchActiveUsers(id: String) -> AnyPublisher<ActiveUsersResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getActiveUsers(websiteId: id)
            .eraseToAnyPublisher()
    }

    func fetchRealtimeSnapshot(websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getRealtime(websiteId: websiteId, timezone: TimeZone.current.identifier)
            .handleEvents(receiveOutput: { [weak self] snapshot in
                self?.setRealtimeSnapshot(snapshot, for: websiteId)
            })
            .eraseToAnyPublisher()
    }

    func latestRealtimeSnapshot(for websiteId: String) -> RealtimeData? {
        guard let entry = realtimeSnapshots[websiteId] else { return nil }
        if entry.expiryDate < nowProvider() {
            realtimeSnapshots.removeValue(forKey: websiteId)
            return nil
        }
        return entry.value as? RealtimeData
    }

    func fetchWebsiteEvents(
        id: String,
        period: StatsPeriod = .day,
        page: Int = 1,
        pageSize: Int = AnalyticsRuntimeConfig.default.eventsSessionsPageSize,
        search: String? = nil,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(
            prefix: "events",
            websiteId: id,
            period: period,
            extras: ["\(page)", "\(pageSize)", search ?? "", query.cacheKey]
        )
        if let cached: PaginatedResponse<AnalyticsRecord> = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteEvents(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search, query: query)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteEventSeries(
        id: String,
        period: StatsPeriod = .day,
        eventName: String? = nil,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[TimeSeriesData], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventSeries", websiteId: id, period: period, extras: [eventName ?? "", query.cacheKey])
        if let cached: [TimeSeriesData] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteEventSeries(id: id, dateRange: dateRange, eventName: eventName, query: query)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteValues(
        id: String,
        type: String,
        period: StatsPeriod = .day,
        search: String? = nil,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "values", websiteId: id, period: period, extras: [type, search ?? "", query.cacheKey])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteValues(id: id, type: type, dateRange: dateRange, search: search, query: query)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchEventDataEvents(
        id: String,
        period: StatsPeriod = .day,
        event: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventDataEvents", websiteId: id, period: period, extras: [event ?? ""])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataEvents(id: id, dateRange: dateRange, event: event)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchEventDataFields(id: String, period: StatsPeriod = .day) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventDataFields", websiteId: id, period: period)
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataFields(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchEventDataProperties(
        id: String,
        period: StatsPeriod = .day,
        propertyName: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventDataProperties", websiteId: id, period: period, extras: [propertyName ?? ""])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataProperties(id: id, dateRange: dateRange, propertyName: propertyName)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchEventDataStats(
        id: String,
        period: StatsPeriod = .day,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventDataStats", websiteId: id, period: period, extras: [query.cacheKey])
        if let cached: [String: MetricValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataStats(id: id, dateRange: dateRange, query: query)
            .handleEvents(receiveOutput: { [weak self] stats in
                self?.setCachedValue(stats, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchEventDataValues(
        id: String,
        period: StatsPeriod = .day,
        eventName: String? = nil,
        propertyName: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(
            prefix: "eventDataValues",
            websiteId: id,
            period: period,
            extras: [eventName ?? "", propertyName ?? ""]
        )
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataValues(id: id, dateRange: dateRange, eventName: eventName, propertyName: propertyName)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchSessionDataProperties(
        id: String,
        period: StatsPeriod = .day,
        propertyName: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionDataProperties", websiteId: id, period: period, extras: [propertyName ?? ""])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getSessionDataProperties(id: id, dateRange: dateRange, propertyName: propertyName)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchSessionDataValues(
        id: String,
        period: StatsPeriod = .day,
        propertyName: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionDataValues", websiteId: id, period: period, extras: [propertyName ?? ""])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getSessionDataValues(id: id, dateRange: dateRange, propertyName: propertyName)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.setCachedValue(values, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessions(
        id: String,
        period: StatsPeriod = .day,
        page: Int = 1,
        pageSize: Int = AnalyticsRuntimeConfig.default.eventsSessionsPageSize,
        search: String? = nil,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(
            prefix: "sessions",
            websiteId: id,
            period: period,
            extras: ["\(page)", "\(pageSize)", search ?? "", query.cacheKey]
        )
        if let cached: PaginatedResponse<AnalyticsRecord> = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessions(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search, query: query)
            .handleEvents(receiveOutput: { [weak self] sessions in
                self?.setCachedValue(sessions, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionStats(
        id: String,
        period: StatsPeriod = .day,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionStats", websiteId: id, period: period, extras: [query.cacheKey])
        if let cached: [String: MetricValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessionStats(id: id, dateRange: dateRange, query: query)
            .handleEvents(receiveOutput: { [weak self] stats in
                self?.setCachedValue(stats, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionsWeekly(
        id: String,
        period: StatsPeriod = .day,
        query: AnalyticsQueryOptions = .default
    ) -> AnyPublisher<[WeeklySessionPoint], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionsWeekly", websiteId: id, period: period, extras: [query.cacheKey])
        if let cached: [WeeklySessionPoint] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessionsWeekly(id: id, dateRange: dateRange, query: query)
            .handleEvents(receiveOutput: { [weak self] data in
                self?.setCachedValue(data, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsiteSession(id: id, sessionId: sessionId)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionActivity(
        id: String,
        sessionId: String,
        period: StatsPeriod = .day
    ) -> AnyPublisher<[AnalyticsRecord], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessionActivity(id: id, sessionId: sessionId, dateRange: dateRange)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionProperties(id: String, sessionId: String) -> AnyPublisher<[String: JSONValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsiteSessionProperties(id: id, sessionId: sessionId)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteReports(websiteId: String) -> AnyPublisher<[SavedReport], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsiteReports(websiteId: websiteId)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSegments(websiteId: String, type: SegmentType?) -> AnyPublisher<[SegmentDefinition], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsiteSegments(websiteId: websiteId, type: type)
    }

    func fetchLinks(teamId: String?) -> AnyPublisher<[TrackedAsset], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getLinks(teamId: teamId)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func fetchPixels(teamId: String?) -> AnyPublisher<[TrackedAsset], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getPixels(teamId: teamId)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func resetWebsite(id: String) -> AnyPublisher<Void, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.resetWebsite(id: id)
    }

    func transferWebsite(id: String, userId: String?, teamId: String?) -> AnyPublisher<Void, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.transferWebsite(id: id, body: TransferWebsiteRequest(userId: userId, teamId: teamId))
    }

    func invalidateAnalyticsCache(for websiteId: String? = nil) {
        if let websiteId {
            analyticsCache.keys
                .filter { $0.contains("|\(websiteId)|") }
                .forEach { analyticsCache.removeValue(forKey: $0) }
            realtimeSnapshots.removeValue(forKey: websiteId)
            return
        }

        analyticsCache.removeAll()
        realtimeSnapshots.removeAll()
    }

    // MARK: - Realtime Data

    func startRealtimeUpdates(
        for websiteId: String,
        interval: TimeInterval = AnalyticsRuntimeConfig.default.realtimePollInterval,
        completion: @escaping (Int) -> Void
    ) {
        stopRealtimeUpdates(for: websiteId)
        let sleepInterval = realtimeSleepInterval(for: interval)
        let taskKey = realtimeLegacyTaskKey(for: websiteId)

        realtimeTasks[taskKey] = Task { @MainActor [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                do {
                    let response = try await self.fetchActiveUsersAsync(id: websiteId)
                    completion(response.visitors)
                } catch {
                    // Keep polling through transient network failures.
                }

                guard !Task.isCancelled else { break }
                try? await Task.sleep(nanoseconds: sleepInterval)
            }
        }
    }

    func stopRealtimeUpdates(for websiteId: String) {
        let taskKey = realtimeLegacyTaskKey(for: websiteId)
        realtimeTasks[taskKey]?.cancel()
        realtimeTasks.removeValue(forKey: taskKey)
    }

    // MARK: - CoreData Operations

    private func saveWebsitesToCoreData(_ websites: [WebsiteModel]) {
        let context = PersistenceController.shared.container.viewContext
        let serverURL = AuthManager.shared.serverURL
        let updatedAt = nowProvider()

        context.perform {
            // Fetch existing server
            let serverFetchRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            if let serverURL {
                serverFetchRequest.predicate = NSPredicate(format: "url == %@", serverURL)

                do {
                    let existingServers = try context.fetch(serverFetchRequest)
                    let server: UmamiServer

                    if let existingServer = existingServers.first {
                        server = existingServer
                    } else {
                        // Create new server if none exists
                        server = UmamiServer(context: context)
                        server.url = serverURL
                        server.name = "Umami Server"
                    }

                    // Create or update websites
                    for website in websites {
                        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
                        websiteFetchRequest.predicate = NSPredicate(format: "id == %@ AND server == %@", website.id, server)

                        let existingWebsites = try context.fetch(websiteFetchRequest)

                        if let existingWebsite = existingWebsites.first {
                            // Update existing website
                            existingWebsite.name = website.name
                            existingWebsite.domain = website.domain
                            existingWebsite.lastUpdated = updatedAt
                        } else {
                            // Create new website
                            let newWebsite = UmamiWebsite(context: context)
                            newWebsite.id = website.id
                            newWebsite.name = website.name
                            newWebsite.domain = website.domain
                            newWebsite.lastUpdated = updatedAt
                            newWebsite.server = server
                        }
                    }

                    try context.save()
                } catch {
                    self.logger.error("Failed to save websites to Core Data: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    private func deleteWebsiteFromCoreData(_ websiteId: String) {
        let context = PersistenceController.shared.container.viewContext
        let serverURL = AuthManager.shared.serverURL

        context.perform {
            guard let serverURL else { return }

            let serverFetchRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            serverFetchRequest.predicate = NSPredicate(format: "url == %@", serverURL)

            let fetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()

            do {
                guard let server = try context.fetch(serverFetchRequest).first else { return }
                fetchRequest.predicate = NSPredicate(format: "id == %@ AND server == %@", websiteId, server)
                let results = try context.fetch(fetchRequest)
                for object in results {
                    context.delete(object)
                }

                if context.hasChanges {
                    try context.save()
                }
            } catch {
                self.logger.error("Failed to delete website from Core Data: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func saveStatsToCache(websiteId: String, stats: WebsiteStatsResponse, period: StatsPeriod) {
        let context = PersistenceController.shared.container.viewContext
        let updatedAt = nowProvider()
        let serverURL = AuthManager.shared.serverURL

        context.perform {
            guard let serverURL else { return }

            // Fetch the website
            let serverFetchRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            serverFetchRequest.predicate = NSPredicate(format: "url == %@", serverURL)
            let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()

            do {
                guard let server = try context.fetch(serverFetchRequest).first else { return }
                websiteFetchRequest.predicate = NSPredicate(format: "id == %@ AND server == %@", websiteId, server)
                let websites = try context.fetch(websiteFetchRequest)

                if let website = websites.first {
                    // Create or update stats
                    let statsFetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
                    statsFetchRequest.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                    let existingStats = try context.fetch(statsFetchRequest)

                    if let existingStats = existingStats.first {
                        // Update existing stats
                        existingStats.pageviews = Int64(stats.pageviews)
                        existingStats.visitors = Int64(stats.visitors)
                        existingStats.bounceRate = stats.bounceRate
                        existingStats.avgDuration = stats.avgDuration
                        existingStats.date = updatedAt
                    } else {
                        // Create new stats
                        let newStats = UmamiWebsiteStats(context: context)
                        newStats.website = website
                        newStats.pageviews = Int64(stats.pageviews)
                        newStats.visitors = Int64(stats.visitors)
                        newStats.bounceRate = stats.bounceRate
                        newStats.avgDuration = stats.avgDuration
                        newStats.date = updatedAt
                        newStats.period = period.rawValue
                    }

                    try context.save()
                }
            } catch {
                self.logger.error("Failed to save website stats to Core Data: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private func saveMetricsToCache(websiteId: String, metrics: WebsiteMetricsResponse, period: StatsPeriod) {
        guard !metrics.isEmpty else { return }
        logger.debug("Received \(metrics.count) metrics entries for website \(websiteId, privacy: .private(mask: .hash)) and period \(period.rawValue, privacy: .public).")
    }

    // MARK: - Helper Methods

    private func makeCacheKey(prefix: String, websiteId: String, period: StatsPeriod, extras: [String] = []) -> String {
        let sessionIdentifier = AuthManager.shared.currentSession?.identifier ?? "sessionless"
        let extraSegment = extras.joined(separator: "|")
        return "\(sessionIdentifier)|\(prefix)|\(websiteId)|\(period.rawValue)|\(extraSegment)"
    }

    private func logCacheDebug(_ message: @autoclosure () -> String) {
    #if DEBUG
        let resolvedMessage = message()
        logger.debug("\(resolvedMessage, privacy: .public)")
    #endif
    }

    private func cachedValue<T>(for key: String) -> T? {
        guard var entry = analyticsCache[key] else {
            logCacheDebug("CACHE MISS (absent): \(key)")
            return nil
        }

        if entry.expiryDate < nowProvider() {
            analyticsCache.removeValue(forKey: key)
            logCacheDebug("CACHE MISS (expired): \(key)")
            return nil
        }

        entry.lastAccessDate = nowProvider()
        analyticsCache[key] = entry
        logCacheDebug("CACHE HIT: \(key) [\(analyticsCache.count) entries]")
        return entry.value as? T
    }

    private func setCachedValue<T>(_ value: T, for key: String, ttl: TimeInterval? = nil) {
        let now = nowProvider()
        let expiry = now.addingTimeInterval(ttl ?? analyticsCacheTTL)
        analyticsCache[key] = CacheEntry(expiryDate: expiry, value: value, lastAccessDate: now)
        evictIfNeeded()
    }

    private func evictIfNeeded() {
        guard analyticsCache.count > analyticsCacheMaxEntries else { return }

        let now = nowProvider()
        let expiredKeys = analyticsCache.filter { $0.value.expiryDate < now }.map(\.key)
        for key in expiredKeys {
            analyticsCache.removeValue(forKey: key)
        }

        if !expiredKeys.isEmpty {
            logCacheDebug("CACHE EVICT: \(expiredKeys.count) expired entries removed")
        }

        guard analyticsCache.count > analyticsCacheMaxEntries else { return }

        let sorted = analyticsCache.sorted { $0.value.lastAccessDate < $1.value.lastAccessDate }
        let toEvict = analyticsCache.count - analyticsCacheMaxEntries
        for (key, _) in sorted.prefix(toEvict) {
            analyticsCache.removeValue(forKey: key)
        }
        logCacheDebug("CACHE EVICT: \(toEvict) LRU entries removed, \(analyticsCache.count) remaining")
    }

    private func deduplicatedFetch<T>(key: String, fetch: @escaping @MainActor () async throws -> T) async throws -> T {
        if let cached: T = cachedValue(for: key) { return cached }

        let waiterID = UUID()
        let task: Task<InFlightValue, Error>

        if var inFlightEntry = inFlightTasks[key] {
            logCacheDebug("DEDUP JOIN: \(key)")
            inFlightEntry.waiterIDs.insert(waiterID)
            inFlightTasks[key] = inFlightEntry
            task = inFlightEntry.task
        } else {
            logCacheDebug("FETCH START: \(key)")
            task = Task { @MainActor [weak self] () throws -> InFlightValue in
                defer {
                    self?.inFlightTasks.removeValue(forKey: key)
                }
                let result = try await fetch()
                self?.setCachedValue(result, for: key)
                return InFlightValue(value: result)
            }
            inFlightTasks[key] = InFlightEntry(task: task, waiterIDs: [waiterID])
        }

        let waiter = InFlightWaiter()
        let value = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                waiter.setContinuation(continuation)
                waiter.setObserverTask(Task { [weak self, waiter] in
                    do {
                        let value = try await task.value
                        await MainActor.run {
                            self?.releaseInFlightWaiter(waiterID, for: key)
                        }
                        waiter.resume(returning: value)
                    } catch {
                        await MainActor.run {
                            self?.releaseInFlightWaiter(waiterID, for: key)
                        }
                        waiter.resume(throwing: error)
                    }
                })
            }
        } onCancel: { [weak self] in
            waiter.cancelObserver()
            waiter.resume(throwing: CancellationError())
            Task { @MainActor in
                self?.releaseInFlightWaiter(waiterID, for: key)
            }
        }
        guard let typed = value.value as? T else {
            throw APIError.decodingError
        }
        return typed
    }

    private func releaseInFlightWaiter(_ waiterID: UUID, for key: String) {
        guard var entry = inFlightTasks[key],
              entry.waiterIDs.remove(waiterID) != nil else {
            return
        }

        if entry.waiterIDs.isEmpty {
            entry.task.cancel()
            inFlightTasks.removeValue(forKey: key)
        } else {
            inFlightTasks[key] = entry
        }
    }

    private func setRealtimeSnapshot(_ snapshot: RealtimeData, for websiteId: String) {
        let now = nowProvider()
        let expiry = now.addingTimeInterval(realtimeSnapshotTTL)
        realtimeSnapshots[websiteId] = CacheEntry(expiryDate: expiry, value: snapshot, lastAccessDate: now)
    }

    private func realtimeSleepInterval(for interval: TimeInterval) -> UInt64 {
        UInt64(max(interval, 0.05) * 1_000_000_000)
    }

    private func createDateRange(for period: StatsPeriod) -> DateRange {
        let now = nowProvider()
        let calendar = Calendar.current

        var startDate: Date
        let endDate = now
        let unit: String

        switch period {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -1, to: now)!
            unit = "hour"
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            unit = "day"
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            unit = "day"
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
            unit = "month"
        }

        let startTimestamp = Int64(startDate.timeIntervalSince1970 * 1000)
        let endTimestamp = Int64(endDate.timeIntervalSince1970 * 1000)

        return DateRange(
            startAt: startTimestamp,
            endAt: endTimestamp,
            unit: unit,
            timezone: TimeZone.current.identifier
        )
    }

    // MARK: - Fetch from CoreData

    func fetchCachedWebsites() -> [UmamiWebsite] {
        let context = PersistenceController.shared.container.viewContext
        guard let serverURL = AuthManager.shared.serverURL else {
            return []
        }
        let fetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "lastUpdated", ascending: false),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "server.url == %@", serverURL)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            logger.error("Failed to fetch cached websites: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats? {
        let context = PersistenceController.shared.container.viewContext
        guard let serverURL = AuthManager.shared.serverURL else {
            return nil
        }

        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
        websiteFetchRequest.predicate = NSPredicate(format: "id == %@ AND server.url == %@", websiteId, serverURL)

        do {
            let websites = try context.fetch(websiteFetchRequest)

            if let website = websites.first {
                let statsFetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
                statsFetchRequest.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                let stats = try context.fetch(statsFetchRequest)
                guard let entry = stats.first else { return nil }

                if let date = entry.date, date.addingTimeInterval(coreDataStatsTTL) < nowProvider() {
                    context.delete(entry)
                    try? context.save()
                    return nil
                }

                return entry
            }
        } catch {
            logger.error("Failed to fetch cached stats: \(error.localizedDescription, privacy: .public)")
        }

        return nil
    }

    func purgeExpiredCoreDataStats() {
        let context = PersistenceController.shared.container.viewContext
        let cutoff = nowProvider().addingTimeInterval(-coreDataStatsTTL) as NSDate

        context.perform { [logger] in
            let fetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date < %@", cutoff)

            do {
                let stale = try context.fetch(fetchRequest)
                guard !stale.isEmpty else { return }
                for record in stale {
                    context.delete(record)
                }
                try context.save()
                logger.debug("Purged \(stale.count) expired CoreData stats records")
            } catch {
                logger.error("Failed to purge expired stats: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

// MARK: - Async/Await Implementations

extension WebsiteService {
    func fetchWebsitesAsync() async throws -> [WebsiteModel] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        if let session = AuthManager.shared.currentSession,
           session.serverType == .publicShare,
           let websiteId = session.sharedWebsiteId {
            let website = try await apiClient.getWebsiteAsync(id: websiteId)
            saveWebsitesToCoreData([website])
            return [website]
        }
        let websites = try await apiClient.getAllAccessibleWebsitesAsync()
        saveWebsitesToCoreData(websites)
        return websites
    }

    func fetchWebsiteStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions = .default) async throws -> WebsiteStatsResponse {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "stats", websiteId: id, period: period, extras: [query.cacheKey])
        let response: WebsiteStatsResponse = try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteStatsAsync(id: id, dateRange: dateRange, query: query)
        }
        saveStatsToCache(websiteId: id, stats: response, period: period)
        return response
    }

    func fetchWebsiteMetricsAsync(id: String, period: StatsPeriod, type: String, query: AnalyticsQueryOptions = .default) async throws -> WebsiteMetricsResponse {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "metrics", websiteId: id, period: period, extras: [type, query.cacheKey])
        let response: WebsiteMetricsResponse = try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteMetricsAsync(id: id, dateRange: dateRange, type: type, query: query)
        }
        saveMetricsToCache(websiteId: id, metrics: response, period: period)
        return response
    }

    func fetchWebsitePageviewsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions = .default) async throws -> PageviewsResponse {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "pageviews", websiteId: id, period: period, extras: [query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsitePageviewsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func fetchActiveUsersAsync(id: String) async throws -> ActiveUsersResponse {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        return try await apiClient.getActiveUsersAsync(websiteId: id)
    }

    func fetchRealtimeSnapshotAsync(websiteId: String) async throws -> RealtimeData {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let snapshot = try await apiClient.getRealtimeAsync(websiteId: websiteId, timezone: TimeZone.current.identifier)
        setRealtimeSnapshot(snapshot, for: websiteId)
        return snapshot
    }

    func fetchWebsiteEventSeriesAsync(id: String, period: StatsPeriod, eventName: String?, query: AnalyticsQueryOptions = .default) async throws -> [TimeSeriesData] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventSeries", websiteId: id, period: period, extras: [eventName ?? "", query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteEventSeriesAsync(id: id, dateRange: dateRange, eventName: eventName, query: query)
        }
    }

    func fetchWebsiteEventsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions = .default) async throws -> PaginatedResponse<AnalyticsRecord> {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "events", websiteId: id, period: period, extras: ["\(page)", "\(pageSize)", search ?? "", query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteEventsAsync(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search, query: query)
        }
    }

    func fetchWebsiteValuesAsync(id: String, type: String, period: StatsPeriod, search: String?, query: AnalyticsQueryOptions = .default) async throws -> [FilterValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "values", websiteId: id, period: period, extras: [type, search ?? "", query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteValuesAsync(id: id, type: type, dateRange: dateRange, search: search, query: query)
        }
    }

    func fetchEventDataFieldsAsync(id: String, period: StatsPeriod) async throws -> [FilterValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventDataFields", websiteId: id, period: period)
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getEventDataFieldsAsync(id: id, dateRange: dateRange)
        }
    }

    func fetchEventDataPropertiesAsync(id: String, period: StatsPeriod, propertyName: String?) async throws -> [FilterValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventDataProperties", websiteId: id, period: period, extras: [propertyName ?? ""])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getEventDataPropertiesAsync(id: id, dateRange: dateRange, propertyName: propertyName)
        }
    }

    func fetchEventDataEventsAsync(id: String, period: StatsPeriod, event: String?) async throws -> [FilterValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventDataEvents", websiteId: id, period: period, extras: [event ?? ""])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getEventDataEventsAsync(id: id, dateRange: dateRange, event: event)
        }
    }

    func fetchEventDataStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions = .default) async throws -> [String: MetricValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventDataStats", websiteId: id, period: period, extras: [query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getEventDataStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func fetchEventDataValuesAsync(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) async throws -> [FilterValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "eventDataValues", websiteId: id, period: period, extras: [eventName ?? "", propertyName ?? ""])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getEventDataValuesAsync(id: id, dateRange: dateRange, eventName: eventName, propertyName: propertyName)
        }
    }

    func fetchWebsiteSessionStatsAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions = .default) async throws -> [String: MetricValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "sessionStats", websiteId: id, period: period, extras: [query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteSessionStatsAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func fetchWebsiteSessionsWeeklyAsync(id: String, period: StatsPeriod, query: AnalyticsQueryOptions = .default) async throws -> [WeeklySessionPoint] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "sessionsWeekly", websiteId: id, period: period, extras: [query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteSessionsWeeklyAsync(id: id, dateRange: dateRange, query: query)
        }
    }

    func fetchWebsiteSessionsAsync(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?, query: AnalyticsQueryOptions = .default) async throws -> PaginatedResponse<AnalyticsRecord> {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let cacheKey = makeCacheKey(prefix: "sessions", websiteId: id, period: period, extras: ["\(page)", "\(pageSize)", search ?? "", query.cacheKey])
        return try await deduplicatedFetch(key: cacheKey) {
            let dateRange = self.createDateRange(for: period)
            return try await apiClient.getWebsiteSessionsAsync(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search, query: query)
        }
    }

    func fetchWebsiteSessionAsync(id: String, sessionId: String) async throws -> AnalyticsRecord {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        return try await apiClient.getWebsiteSessionAsync(id: id, sessionId: sessionId)
    }

    func fetchWebsiteSessionActivityAsync(id: String, sessionId: String, period: StatsPeriod) async throws -> [AnalyticsRecord] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let dateRange = createDateRange(for: period)
        return try await apiClient.getWebsiteSessionActivityAsync(id: id, sessionId: sessionId, dateRange: dateRange)
    }

    func fetchWebsiteSessionPropertiesAsync(id: String, sessionId: String) async throws -> [String: JSONValue] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        return try await apiClient.getWebsiteSessionPropertiesAsync(id: id, sessionId: sessionId)
    }

    func fetchWebsiteReportsAsync(websiteId: String) async throws -> [SavedReport] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let response = try await apiClient.getWebsiteReportsAsync(websiteId: websiteId)
        return response.data
    }

    func fetchWebsiteSegmentsAsync(websiteId: String, type: SegmentType?) async throws -> [SegmentDefinition] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        return try await apiClient.getWebsiteSegmentsAsync(websiteId: websiteId, type: type)
    }

    func fetchLinksAsync(teamId: String?) async throws -> [TrackedAsset] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let response = try await apiClient.getLinksAsync(teamId: teamId)
        return response.data
    }

    func fetchPixelsAsync(teamId: String?) async throws -> [TrackedAsset] {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let response = try await apiClient.getPixelsAsync(teamId: teamId)
        return response.data
    }

    func createWebsiteAsync(name: String, domain: String, shareId: String?, teamId: String?, id: String?) async throws -> WebsiteModel {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let payload = CreateWebsiteRequest(name: name, domain: domain, shareId: shareId, teamId: teamId, id: id)
        let website = try await apiClient.createWebsiteAsync(body: payload)
        saveWebsitesToCoreData([website])
        return website
    }

    func updateWebsiteAsync(id: String, name: String?, domain: String?, shareId: String?) async throws -> WebsiteModel {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        let payload = UpdateWebsiteRequest(name: name, domain: domain, shareId: shareId)
        let website = try await apiClient.updateWebsiteAsync(id: id, body: payload)
        saveWebsitesToCoreData([website])
        return website
    }

    func deleteWebsiteAsync(id: String) async throws {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        try await apiClient.deleteWebsiteAsync(id: id)
        deleteWebsiteFromCoreData(id)
        invalidateAnalyticsCache(for: id)
    }

    func resetWebsiteAsync(id: String) async throws {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        try await apiClient.resetWebsiteAsync(id: id)
        invalidateAnalyticsCache(for: id)
    }

    func transferWebsiteAsync(id: String, userId: String?, teamId: String?) async throws {
        guard let apiClient = apiClientProvider() else { throw APIError.unauthorized }
        try await apiClient.transferWebsiteAsync(id: id, body: TransferWebsiteRequest(userId: userId, teamId: teamId))
        invalidateAnalyticsCache(for: id)
    }

    func startRealtimeUpdatesAsync(for websiteId: String, interval: TimeInterval = AnalyticsRuntimeConfig.default.realtimePollInterval) -> AsyncStream<Int> {
        let sleepInterval = realtimeSleepInterval(for: interval)
        let taskKey = realtimeAsyncTaskKey(for: websiteId)

        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task { @MainActor [weak self] in
                defer { continuation.finish() }

                while !Task.isCancelled {
                    do {
                        guard let self else {
                            return
                        }
                        let response = try await self.fetchActiveUsersAsync(id: websiteId)
                        continuation.yield(response.visitors)
                    } catch {
                        // Continue polling on error
                    }
                    guard !Task.isCancelled else { break }
                    try? await Task.sleep(nanoseconds: sleepInterval)
                }
            }

            realtimeTasks[taskKey] = task

            continuation.onTermination = { _ in
                Task { @MainActor [weak self] in
                    task.cancel()
                    self?.realtimeTasks.removeValue(forKey: taskKey)
                }
            }
        }
    }

    func stopRealtimeUpdatesAsync(for websiteId: String) {
        let prefix = "async:\(websiteId):"
        let taskKeys = realtimeTasks.keys.filter { $0.hasPrefix(prefix) }
        for taskKey in taskKeys {
            realtimeTasks[taskKey]?.cancel()
            realtimeTasks.removeValue(forKey: taskKey)
        }
    }

    private func realtimeLegacyTaskKey(for websiteId: String) -> String {
        "legacy:\(websiteId)"
    }

    private func realtimeAsyncTaskKey(for websiteId: String) -> String {
        "async:\(websiteId):\(UUID().uuidString)"
    }
}

// MARK: - Helper Types

enum StatsPeriod: String, Sendable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"

    var displayName: String {
        switch self {
        case .day: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}
