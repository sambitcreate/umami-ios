//
//  WebsiteService.swift
//  Umami Analytics
//
//  Created by Augment on 4/17/25.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class WebsiteService {
    static let shared = WebsiteService()

    private var cancellables = Set<AnyCancellable>()
    private var realtimeTimers: [String: Timer] = [:]

    // MARK: - Website List

    func fetchWebsites() -> AnyPublisher<[WebsiteModel], Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            return Just(DebugManager.shared.getMockWebsites())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsites()
            .map { response in
                return response.data
            }
            .handleEvents(receiveOutput: { [weak self] websites in
                self?.saveWebsitesToCoreData(websites)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Website Details

    func fetchWebsiteDetails(id: String) -> AnyPublisher<WebsiteModel, Error> {
        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        return apiClient.getWebsite(id: id)
            .eraseToAnyPublisher()
    }

    // MARK: - Website Stats

    func fetchWebsiteStats(id: String, period: StatsPeriod = .day) -> AnyPublisher<WebsiteStatsResponse, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            let mockStats = DebugManager.shared.getMockStats()
            let now = Date()
            let startDate = createDateRange(for: period).startAt

            let response = WebsiteStatsResponse(
                websiteId: id,
                startDate: ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(startDate) / 1000)),
                endDate: ISO8601DateFormatter().string(from: now),
                stats: mockStats
            )

            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        let publisher = apiClient.getWebsiteStats(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveStatsToCache(websiteId: id, stats: response.stats, period: period)
            })

        return publisher.catch { error -> AnyPublisher<WebsiteStatsResponse, Error> in
            // If we get a 404 error, it might be an API version compatibility issue
            if case APIError.endpointNotFound = error {
                print("⚠️ API endpoint not found for stats. This might be due to API version incompatibility.")

                // Try to load from cache as a fallback
                if let cachedStats = self.fetchCachedStats(for: id, period: period) {
                    let stats = WebsiteStatsModel(
                        pageviews: Int(cachedStats.pageviews),
                        uniques: Int(cachedStats.visitors),
                        bounces: 0, // Not stored in our simple cache
                        totalTime: 0 // Not stored in our simple cache
                    )

                    let now = Date()
                    let dateRange = self.createDateRange(for: period)

                    let response = WebsiteStatsResponse(
                        websiteId: id,
                        startDate: ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(dateRange.startAt) / 1000)),
                        endDate: ISO8601DateFormatter().string(from: now),
                        stats: stats
                    )

                    return Just(response)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }

            // If we can't handle the error or don't have cached data, just pass it through
            return Fail(error: error).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    // MARK: - Website Metrics

    func fetchWebsiteMetrics(id: String, period: StatsPeriod = .day) -> AnyPublisher<WebsiteMetricsResponse, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            let mockMetrics = DebugManager.shared.getMockMetrics()
            let now = Date()
            let startDate = createDateRange(for: period).startAt

            let response = WebsiteMetricsResponse(
                websiteId: id,
                startDate: ISO8601DateFormatter().string(from: Date(timeIntervalSince1970: Double(startDate) / 1000)),
                endDate: ISO8601DateFormatter().string(from: now),
                metrics: mockMetrics
            )

            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        let dateRange = createDateRange(for: period)

        let publisher = apiClient.getWebsiteMetrics(id: id, dateRange: dateRange)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.saveMetricsToCache(websiteId: id, metrics: response.metrics, period: period)
            })

        return publisher.catch { error -> AnyPublisher<WebsiteMetricsResponse, Error> in
            // Log the error but don't use mock data
            if case APIError.endpointNotFound = error {
                print("⚠️ API endpoint not found for metrics. This might be due to an API version incompatibility.")
            } else {
                print("⚠️ Error fetching metrics: \(error.localizedDescription)")
            }

            // Pass the error through
            return Fail(error: error).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    // MARK: - Realtime Data

    func startRealtimeUpdates(for websiteId: String, interval: TimeInterval = 5.0, completion: @escaping (RealtimeData) -> Void) {
        stopRealtimeUpdates(for: websiteId)

        // Fetch initial data
        fetchRealtimeData(for: websiteId)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print("⚠️ Error fetching initial realtime data: \(error.localizedDescription)")
                        // If initial fetch fails, still provide mock data so UI isn't empty
                        let mockData = DebugManager.shared.getMockRealtimeData()
                        completion(mockData)
                    }
                },
                receiveValue: { data in
                    completion(data)
                }
            )
            .store(in: &cancellables)

        // Set up timer for periodic updates
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fetchRealtimeData(for: websiteId)
                .sink(
                    receiveCompletion: { result in
                        if case .failure(let error) = result {
                            print("⚠️ Error fetching realtime data update: \(error.localizedDescription)")
                            // Don't provide mock data on subsequent failures to avoid UI flicker
                        }
                    },
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

    private func fetchRealtimeData(for websiteId: String) -> AnyPublisher<RealtimeData, Error> {
        // If in debug mode, return mock data
        if DebugManager.shared.isDebugMode {
            return Just(DebugManager.shared.getMockRealtimeData())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let apiClient = AuthManager.shared.apiClient else {
            return Fail(error: APIError.unauthorized).eraseToAnyPublisher()
        }

        // Track persistent failures but don't use mock data
        let persistentFailureCount = UserDefaults.standard.integer(forKey: "umami_realtime_failure_count")
        if persistentFailureCount > 3 {
            print("⚠️ Note: Multiple persistent failures with realtime data")
        }

        let publisher = apiClient.getRealtimeData(websiteId: websiteId)

        return publisher.catch { error -> AnyPublisher<RealtimeData, Error> in
            // Log the error but don't use mock data
            if case APIError.endpointNotFound = error {
                print("⚠️ API endpoint not found for realtime data. This might be due to API version incompatibility.")

                // Increment the failure counter for tracking purposes
                let currentCount = UserDefaults.standard.integer(forKey: "umami_realtime_failure_count")
                UserDefaults.standard.set(currentCount + 1, forKey: "umami_realtime_failure_count")
            } else if case APIError.serverError = error {
                print("⚠️ Server error for realtime data: \(error.localizedDescription)")
            } else {
                print("⚠️ Error fetching realtime data: \(error.localizedDescription)")
            }

            // Pass the error through
            return Fail(error: error).eraseToAnyPublisher()
        }
        .handleEvents(receiveOutput: { _ in
            // On success, reset the failure counter
            UserDefaults.standard.set(0, forKey: "umami_realtime_failure_count")
        })
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
                            existingWebsite.lastUpdated = Date()
                        } else {
                            // Create new website
                            let newWebsite = UmamiWebsite(context: context)
                            newWebsite.id = website.id
                            newWebsite.name = website.name
                            newWebsite.domain = website.domain
                            newWebsite.lastUpdated = Date()
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

    private func saveStatsToCache(websiteId: String, stats: WebsiteStatsModel, period: StatsPeriod) {
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
                        existingStats.visitors = Int64(stats.uniques)
                        existingStats.date = Date()
                    } else {
                        // Create new stats
                        let newStats = UmamiWebsiteStats(context: context)
                        newStats.website = website
                        newStats.pageviews = Int64(stats.pageviews)
                        newStats.visitors = Int64(stats.uniques)
                        newStats.date = Date()
                        newStats.period = period.rawValue
                    }

                    try context.save()
                }
            } catch {
                print("Error saving stats to CoreData: \(error)")
            }
        }
    }

    private func saveMetricsToCache(websiteId: String, metrics: WebsiteMetrics, period: StatsPeriod) {
        let context = PersistenceController.shared.container.viewContext

        context.perform {
            // Fetch the website
            let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
            websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

            do {
                let websites = try context.fetch(websiteFetchRequest)
                guard let website = websites.first else { return }

                // Encode series we chart: pageviews and sessions, and cache top pages/referrers/browsers/devices/countries
                let encoder = JSONEncoder()
                guard let pvData = try? encoder.encode(metrics.pageviews),
                      let sessionsData = try? encoder.encode(metrics.sessions),
                      let pagesData = try? encoder.encode(metrics.pages),
                      let referrersData = try? encoder.encode(metrics.referrers),
                      let browsersData = try? encoder.encode(metrics.browsers),
                      let devicesData = try? encoder.encode(metrics.devices),
                      let countriesData = try? encoder.encode(metrics.countries) else {
                    return
                }

                // Fetch or create cache entity
                let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UmamiWebsiteMetrics")
                fetch.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

                let existing = try context.fetch(fetch).first
                let cacheObject: NSManagedObject
                if let existing = existing {
                    cacheObject = existing
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: "UmamiWebsiteMetrics", in: context)!
                    cacheObject = NSManagedObject(entity: entity, insertInto: context)
                    cacheObject.setValue(website, forKey: "website")
                    cacheObject.setValue(period.rawValue, forKey: "period")
                }

                cacheObject.setValue(Date(), forKey: "date")
                cacheObject.setValue(pvData, forKey: "pageviewsData")
                cacheObject.setValue(sessionsData, forKey: "sessionsData")
                cacheObject.setValue(pagesData, forKey: "pagesData")
                cacheObject.setValue(referrersData, forKey: "referrersData")
                cacheObject.setValue(browsersData, forKey: "browsersData")
                cacheObject.setValue(devicesData, forKey: "devicesData")
                cacheObject.setValue(countriesData, forKey: "countriesData")

                try context.save()
            } catch {
                print("Error saving metrics to CoreData: \(error)")
            }
        }
    }

    func fetchCachedMetrics(for websiteId: String, period: StatsPeriod) -> (WebsiteMetrics, Date)? {
        let context = PersistenceController.shared.container.viewContext

        // Fetch the website first
        let websiteFetchRequest: NSFetchRequest<UmamiWebsite> = UmamiWebsite.fetchRequest()
        websiteFetchRequest.predicate = NSPredicate(format: "id == %@", websiteId)

        do {
            let websites = try context.fetch(websiteFetchRequest)
            guard let website = websites.first else { return nil }

            let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UmamiWebsiteMetrics")
            fetch.predicate = NSPredicate(format: "website == %@ AND period == %@", website, period.rawValue)

            if let cache = try context.fetch(fetch).first,
               let pvData = cache.value(forKey: "pageviewsData") as? Data,
               let sessionsData = cache.value(forKey: "sessionsData") as? Data,
               let date = cache.value(forKey: "date") as? Date {

                let decoder = JSONDecoder()
                let pageviews = (try? decoder.decode([PageviewMetric].self, from: pvData)) ?? []
                let sessions = (try? decoder.decode([SessionMetric].self, from: sessionsData)) ?? []
                let pages = (cache.value(forKey: "pagesData") as? Data).flatMap { try? decoder.decode([PageMetric].self, from: $0) } ?? []
                let referrers = (cache.value(forKey: "referrersData") as? Data).flatMap { try? decoder.decode([ReferrerMetric].self, from: $0) } ?? []
                let browsers = (cache.value(forKey: "browsersData") as? Data).flatMap { try? decoder.decode([BrowserMetric].self, from: $0) } ?? []
                let devices = (cache.value(forKey: "devicesData") as? Data).flatMap { try? decoder.decode([DeviceMetric].self, from: $0) } ?? []
                let countries = (cache.value(forKey: "countriesData") as? Data).flatMap { try? decoder.decode([CountryMetric].self, from: $0) } ?? []

                let metrics = WebsiteMetrics(
                    pageviews: pageviews,
                    sessions: sessions,
                    events: [],
                    countries: countries,
                    browsers: browsers,
                    os: [],
                    devices: devices,
                    referrers: referrers,
                    pages: pages
                )

                return (metrics, date)
            }
        } catch {
            print("Error fetching metrics from CoreData: \(error)")
        }

        return nil
    }

    // MARK: - Helper Methods

    private func createDateRange(for period: StatsPeriod) -> DateRange {
        let now = Date()
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

        // Ensure we're using whole numbers for timestamps
        let startTimestamp = Int64(floor(startDate.timeIntervalSince1970 * 1000))
        let endTimestamp = Int64(floor(endDate.timeIntervalSince1970 * 1000))

        // Validate timestamps to ensure they're not NaN
        let validStartTimestamp = startTimestamp > 0 ? startTimestamp : Int64(Date().timeIntervalSince1970 * 1000) - 86400000 // 24 hours in milliseconds
        let validEndTimestamp = endTimestamp > 0 ? endTimestamp : Int64(Date().timeIntervalSince1970 * 1000)

        print("📅 Date range: \(validStartTimestamp) to \(validEndTimestamp)")

        return DateRange(
            startAt: validStartTimestamp,
            endAt: validEndTimestamp,
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

    // Convenience helper to convert cached CoreData stats into the in-app model
    static func convertCachedStatsToModel(_ cached: UmamiWebsiteStats) -> WebsiteStatsModel {
        WebsiteStatsModel(
            pageviews: Int(cached.pageviews),
            uniques: Int(cached.visitors),
            bounces: 0,
            totalTime: 0
        )
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
