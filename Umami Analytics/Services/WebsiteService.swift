//
//  WebsiteService.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import CoreData

protocol WebsiteServicing {
    func createWebsite(name: String, domain: String, shareId: String?, teamId: String?, id: String?) -> AnyPublisher<WebsiteModel, Error>
    func updateWebsite(id: String, name: String?, domain: String?, shareId: String?) -> AnyPublisher<WebsiteModel, Error>
    func deleteWebsite(id: String) -> AnyPublisher<Void, Error>

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error>
    func fetchWebsiteStats(id: String, period: StatsPeriod) -> AnyPublisher<WebsiteStatsResponse, Error>
    func fetchWebsiteMetrics(id: String, period: StatsPeriod, type: String) -> AnyPublisher<WebsiteMetricsResponse, Error>
    func fetchWebsitePageviews(id: String, period: StatsPeriod) -> AnyPublisher<PageviewsResponse, Error>
    func fetchActiveUsers(id: String) -> AnyPublisher<ActiveUsersResponse, Error>
    func fetchRealtimeSnapshot(websiteId: String) -> AnyPublisher<RealtimeData, Error>
    func fetchWebsiteEventSeries(id: String, period: StatsPeriod, eventName: String?) -> AnyPublisher<[TimeSeriesData], Error>
    func fetchWebsiteEvents(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error>
    func fetchEventDataFields(id: String, period: StatsPeriod) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataProperties(id: String, period: StatsPeriod, propertyName: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataEvents(id: String, period: StatsPeriod, event: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchEventDataStats(id: String, period: StatsPeriod) -> AnyPublisher<[String: MetricValue], Error>
    func fetchEventDataValues(id: String, period: StatsPeriod, eventName: String?, propertyName: String?) -> AnyPublisher<[FilterValue], Error>
    func fetchWebsiteSessionStats(id: String, period: StatsPeriod) -> AnyPublisher<[String: MetricValue], Error>
    func fetchWebsiteSessionsWeekly(id: String, period: StatsPeriod) -> AnyPublisher<[WeeklySessionPoint], Error>
    func fetchWebsiteSessions(id: String, period: StatsPeriod, page: Int, pageSize: Int, search: String?) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error>
    func fetchWebsiteSession(id: String, sessionId: String) -> AnyPublisher<AnalyticsRecord, Error>
    func fetchWebsiteSessionActivity(id: String, sessionId: String, period: StatsPeriod) -> AnyPublisher<[AnalyticsRecord], Error>
    func fetchWebsiteSessionProperties(id: String, sessionId: String) -> AnyPublisher<[String: JSONValue], Error>

    func invalidateAnalyticsCache(for websiteId: String?)
    func startRealtimeUpdates(for websiteId: String, interval: TimeInterval, completion: @escaping (Int) -> Void)
    func stopRealtimeUpdates(for websiteId: String)

    func fetchCachedWebsites() -> [UmamiWebsite]
    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats?
}

class WebsiteService: WebsiteServicing {
    static let shared = WebsiteService()

    private var cancellables = Set<AnyCancellable>()
    private var realtimeTimers: [String: Timer] = [:]
    private let apiClientProvider: () -> APIClient?
    private let nowProvider: () -> Date
    private let analyticsCacheTTL: TimeInterval

    private struct CacheEntry {
        let expiryDate: Date
        let value: Any
    }

    private var analyticsCache: [String: CacheEntry] = [:]
    private var realtimeSnapshots: [String: RealtimeData] = [:]

    init(
        apiClientProvider: @escaping () -> APIClient? = { AuthManager.shared.apiClient },
        nowProvider: @escaping () -> Date = Date.init,
        analyticsCacheTTL: TimeInterval = AnalyticsRuntimeConfig.default.analyticsCacheTTL
    ) {
        self.apiClientProvider = apiClientProvider
        self.nowProvider = nowProvider
        self.analyticsCacheTTL = analyticsCacheTTL
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

        return apiClient.getAllWebsites()
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

    func fetchWebsiteStats(id: String, period: StatsPeriod = .day) -> AnyPublisher<WebsiteStatsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteStats(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveStatsToCache(websiteId: id, stats: response, period: period)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Metrics

    func fetchWebsiteMetrics(id: String, period: StatsPeriod = .day, type: String = "path") -> AnyPublisher<WebsiteMetricsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "metrics", websiteId: id, period: period, extras: [type])
        if let cached: WebsiteMetricsResponse = cachedValue(for: cacheKey) {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsiteMetrics(id: id, dateRange: dateRange, type: type)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveMetricsToCache(websiteId: id, metrics: response, period: period)
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Pageviews

    func fetchWebsitePageviews(id: String, period: StatsPeriod = .day) -> AnyPublisher<PageviewsResponse, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        return apiClient.getWebsitePageviews(id: id, dateRange: dateRange)
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
                self?.realtimeSnapshots[websiteId] = snapshot
            })
            .eraseToAnyPublisher()
    }

    func latestRealtimeSnapshot(for websiteId: String) -> RealtimeData? {
        realtimeSnapshots[websiteId]
    }

    func fetchWebsiteEvents(
        id: String,
        period: StatsPeriod = .day,
        page: Int = 1,
        pageSize: Int = AnalyticsRuntimeConfig.default.eventsSessionsPageSize,
        search: String? = nil
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(
            prefix: "events",
            websiteId: id,
            period: period,
            extras: ["\(page)", "\(pageSize)", search ?? ""]
        )
        if let cached: PaginatedResponse<AnalyticsRecord> = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteEvents(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteEventSeries(
        id: String,
        period: StatsPeriod = .day,
        eventName: String? = nil
    ) -> AnyPublisher<[TimeSeriesData], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventSeries", websiteId: id, period: period, extras: [eventName ?? ""])
        if let cached: [TimeSeriesData] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteEventSeries(id: id, dateRange: dateRange, eventName: eventName)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.setCachedValue(response, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteValues(
        id: String,
        type: String,
        period: StatsPeriod = .day,
        search: String? = nil
    ) -> AnyPublisher<[FilterValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "values", websiteId: id, period: period, extras: [type, search ?? ""])
        if let cached: [FilterValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteValues(id: id, type: type, dateRange: dateRange, search: search)
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
        period: StatsPeriod = .day
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "eventDataStats", websiteId: id, period: period)
        if let cached: [String: MetricValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getEventDataStats(id: id, dateRange: dateRange)
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
        search: String? = nil
    ) -> AnyPublisher<PaginatedResponse<AnalyticsRecord>, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(
            prefix: "sessions",
            websiteId: id,
            period: period,
            extras: ["\(page)", "\(pageSize)", search ?? ""]
        )
        if let cached: PaginatedResponse<AnalyticsRecord> = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessions(id: id, dateRange: dateRange, page: page, pageSize: pageSize, search: search)
            .handleEvents(receiveOutput: { [weak self] sessions in
                self?.setCachedValue(sessions, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionStats(
        id: String,
        period: StatsPeriod = .day
    ) -> AnyPublisher<[String: MetricValue], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionStats", websiteId: id, period: period)
        if let cached: [String: MetricValue] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessionStats(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] stats in
                self?.setCachedValue(stats, for: cacheKey)
            })
            .eraseToAnyPublisher()
    }

    func fetchWebsiteSessionsWeekly(
        id: String,
        period: StatsPeriod = .day
    ) -> AnyPublisher<[WeeklySessionPoint], Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let cacheKey = makeCacheKey(prefix: "sessionsWeekly", websiteId: id, period: period)
        if let cached: [WeeklySessionPoint] = cachedValue(for: cacheKey) {
            return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)
        return apiClient.getWebsiteSessionsWeekly(id: id, dateRange: dateRange)
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

        // Fetch initial data
        fetchActiveUsers(for: websiteId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { data in
                    completion(data)
                }
            )
            .store(in: &cancellables)

        // Set up timer for periodic updates
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchActiveUsers(for: websiteId)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { data in
                        completion(data)
                    }
                )
                .store(in: &self.cancellables)
        }

        realtimeTimers[websiteId] = timer
    }

    func stopRealtimeUpdates(for websiteId: String) {
        realtimeTimers[websiteId]?.invalidate()
        realtimeTimers.removeValue(forKey: websiteId)
    }

    private func fetchActiveUsers(for websiteId: String) -> AnyPublisher<Int, Error> {
        guard let apiClient = apiClientProvider() else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getActiveUsers(websiteId: websiteId)
            .map { response in response.visitors }
            .eraseToAnyPublisher()
    }

    // MARK: - CoreData Operations

    private func saveWebsitesToCoreData(_ websites: [WebsiteModel]) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            // Fetch existing server
            let serverFetchRequest: NSFetchRequest<UmamiServer> = UmamiServer.fetchRequest()
            if let serverURL = AuthManager.shared.serverURL {
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
                        websiteFetchRequest.predicate = NSPredicate(format: "id == %@", website.id)

                        let existingWebsites = try context.fetch(websiteFetchRequest)

                        if let existingWebsite = existingWebsites.first {
                            // Update existing website
                            existingWebsite.name = website.name
                            existingWebsite.domain = website.domain
                            existingWebsite.lastUpdated = self.nowProvider()
                        } else {
                            // Create new website
                            let newWebsite = UmamiWebsite(context: context)
                            newWebsite.id = website.id
                            newWebsite.name = website.name
                            newWebsite.domain = website.domain
                            newWebsite.lastUpdated = self.nowProvider()
                            newWebsite.server = server
                        }
                    }

                    try context.save()
                } catch {
                    print("Error saving websites to CoreData: \(error)")
                }
            }
        }
    }

    private func deleteWebsiteFromCoreData(_ websiteId: String) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            let fetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

            do {
                let results = try context.fetch(fetchRequest)
                for object in results {
                    context.delete(object)
                }

                if context.hasChanges {
                    try context.save()
                }
            } catch {
                print("Error deleting website from CoreData: \(error)")
            }
        }
    }

    private func saveStatsToCache(websiteId: String, stats: WebsiteStatsResponse, period: StatsPeriod) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            // Fetch the website
            let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
            websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

            do {
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
                        existingStats.date = self.nowProvider()
                    } else {
                        // Create new stats
                        let newStats = UmamiWebsiteStats(context: context)
                        newStats.website = website
                        newStats.pageviews = Int64(stats.pageviews)
                        newStats.visitors = Int64(stats.visitors)
                        newStats.bounceRate = stats.bounceRate
                        newStats.avgDuration = stats.avgDuration
                        newStats.date = self.nowProvider()
                        newStats.period = period.rawValue
                    }

                    try context.save()
                }
            } catch {
                print("Error saving stats to CoreData: \(error)")
            }
        }
    }

    private func saveMetricsToCache(websiteId: String, metrics: WebsiteMetricsResponse, period: StatsPeriod) {
        // For simplicity, we're not implementing full metrics caching in this example
        // In a real app, you would create additional CoreData entities for each metric type
        print("Metrics received for website \(websiteId) for period \(period.rawValue)")
    }

    // MARK: - Helper Methods

    private func makeCacheKey(prefix: String, websiteId: String, period: StatsPeriod, extras: [String] = []) -> String {
        let extraSegment = extras.joined(separator: "|")
        return "\(prefix)|\(websiteId)|\(period.rawValue)|\(extraSegment)"
    }

    private func cachedValue<T>(for key: String) -> T? {
        guard let entry = analyticsCache[key] else {
            return nil
        }

        if entry.expiryDate < nowProvider() {
            analyticsCache.removeValue(forKey: key)
            return nil
        }

        return entry.value as? T
    }

    private func setCachedValue<T>(_ value: T, for key: String, ttl: TimeInterval? = nil) {
        let expiry = nowProvider().addingTimeInterval(ttl ?? analyticsCacheTTL)
        analyticsCache[key] = CacheEntry(expiryDate: expiry, value: value)
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
        let fetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching websites from CoreData: \(error)")
            return []
        }
    }

    func fetchCachedStats(for websiteId: String, period: StatsPeriod) -> UmamiWebsiteStats? {
        let context = PersistenceController.shared.container.viewContext

        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
        websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

        do {
            let websites = try context.fetch(websiteFetchRequest)

            if let website = websites.first {
                let statsFetchRequest: NSFetchRequest<UmamiWebsiteStats> = UmamiWebsiteStats.fetchRequest()
                statsFetchRequest.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                let stats = try context.fetch(statsFetchRequest)
                return stats.first
            }
        } catch {
            print("Error fetching stats from CoreData: \(error)")
        }

        return nil
    }
}

// MARK: - Helper Types

enum StatsPeriod: String {
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
